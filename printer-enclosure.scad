///
///
/// OpenSCAD Press-fit Acrylic Printer Enclosure
/// By Pat Niemeyer (pat@pat.net) 
/// https://github.com/patniemeyer/enclosure
///
/// This code is messy. If there is any interest in it going forward I'll clean it up!
/// While I did end up with a decent result this could be improved a lot.  Please see the README.md
/// for notes on what worked well and what didn't.
///

include <rounded.scad>;

$fn=50;
O=0.01;  // Negligable offset
OT=0.02; // Negligable offset for thickness

s=24*25.4; //size of the base
sh=1*25.4; // height of the base
mt=0.12*25.4; // material thickness

goho=0.25*25.4; // guide overlap horizontal outside (starting outside the material)
//goho=0.10*25.4; // guide overlap horizontal outside (starting outside the material)
gohi=0.10*25.4; // guide overlap horizontal inside (starting inside the material)

gova=0.5*25.4; // guide overlap vertical above 
govb=0.25*25.4; // guide overlap vertical below (the lip that hangs down over the base)
//govb=0;

gbh=0.10*25.4; // guide bottom height (the glass sits on this)

// Cut out one corner
cutaway=6.0*25.4*1.01;
cutawayx=-cutaway; // remaining section size
cutawayy=-cutaway; // remaining section size

// Corner support
corner_brace_len = -cutawayx;
corner_brace_width = gohi+mt;
corner_brace_height = gova;

rounding=0;

// Hinge param
knuckle_count = 5;               // [3:2:31]
leaf_gauge = goho;
hinge_width  = 56.0;

leaf_height = gova+govb+0.004;
//leaf_height = 0.75*25.4;

component_clearance = 0.5;
throw_angle = -90.0;   // [ -90 : 5 : 180 ]
knuckle_gusset_type = 0;     // [ 0:None, 1:Linear, 2:Circular, 3:Parabolic ]

module base() {
  color("gray")
  cube([s,s,sh], center=true);
}

module glass() {
  color("blue")
  translate([0,0,s/2+sh/2+gbh])
  difference() {
    cube([s,s,s], center=true);
    cube([s-2*mt,s-2*mt,s+.01], center=true);
  }
}

module guide() 
{
  color("silver")
  translate([0,0,sh/2])
  difference() {
    // exterior
    os=s+2*goho;
    union() {
      // above
      translate([0,0,gova/2])
      roundedCube([os,os,gova], rounding, center=true);
      // below
      translate([0,0,-govb/2+rounding])
      roundedCube([os,os,govb+2*rounding], rounding, center=true);
    }

    // remove interior, material inside the edge and inside the interior overhang
    is=s-2*gohi-2*mt;
    cube([is,is,10*25.4], center=true);

    // remove material channel
    glass();
  }
}

module cutaway(x,y) {
  translate([x,0,0])
  cube([s,s*3,3*s], center=true);
  translate([0,y,0])
  cube([s*3,s,3*s], center=true);
}

// show the base
*%difference() {
    base();
    cutaway(cutawayx, cutawayy);
}

//  Show the glass
*difference() {
  glass(); 
  cutaway(cutawayx, cutawayy);
}

module hingeSlice() {
  sliceThickness=0.3;
  rotate([0,0,45])
  translate([0,/*-100*/,0])
  cube([s*2,sliceThickness/*+200*/,3*25.4], center=true);
}

module guideHinge(
  enable_male_leaf             = 1,     // [ 0:No, 1:Yes ]
  enable_female_leaf           = 1,     // [ 0:No, 1:Yes ]
  hinge_outsety = 0,
  hinge_outsetx = 0,
  scalexy=1.0, scalez=1.0
) 
{
  include <hinge.scad>;

  translate([s/2+goho+hinge_outsetx, s/2+goho+hinge_outsety, sh/2+leaf_height/2-govb])
  rotate([90,0,90])
  //color("red")
  scale([scalexy,scalez,scalexy]) 
  hinge();
}

// The corner area to be occupied by the hinge, removed so that the hinge doesn't internally intersect with it.
module cornerCutout(clearance=component_clearance) 
{
  cw=goho+clearance;
  translate([s/2-cw+goho-O, s/2-O, sh/2-govb-O])
  cube([cw*2+OT, goho*2+OT, gova+govb+OT]);

  translate([s/2+goho*2+O, s/2-cw+goho+O, sh/2-govb-O])
  rotate([0,0,90])
  cube([cw*2+OT, goho*2+OT, gova+govb+OT]);
}

// TODO:
BRACE_NONE=0;
BRACE_LEFT=1;
BRACE_RIGHT=2;
BRACE_BOTH=3;

module cornerBrace(left=true) 
{
  interior=mt+gohi;
  cbl = corner_brace_len;
  cbw = corner_brace_width;
  cbh = corner_brace_height;

  // brace left or right
  //xoff = left ? -component_clearance : cbw;
  //yoff = left ? cbw : -component_clearance;

  // brace both
  xoff = cbw;
  yoff = cbw;

  translate([xoff, yoff, 0])
  intersection() 
  {
    union() 
    {
      // side left
      translate([s/2-cbw-interior, s/2-cbl, gova])
      cube([cbw, cbl-interior, cbh], center=false);

      // side top
      translate([s/2-interior, s/2-cbw-interior, gova])
      rotate([0,0,90.0])
      cube([cbw, cbl-interior, cbh], center=false);

      // diagonal
      translate([s/2-interior, s/2-cbl, gova])
      rotate([0,0,45.0])
      translate([0, -cbl/3, 0]) // slide along diagonal
      cube([cbw, cbl*2, cbh], center=false);
    }

    // interior space
    translate([s/2-cbl, s/2-cbl, gova])
    cube([cbl-interior, cbl-interior, cbh], center=false);
  }
}

module cornerElement() {
  difference() {
    guide();
    base();
    glass(); 
    cutaway(cutawayx, cutawayy);
  }
}

// A corner with optional hinge and brace
module corner(hinge=true, brace=BRACE_LEFT) {
  // The guide
  difference() {
    //guide();
    //base();
    //glass(); 
    //cutaway(cutawayx, cutawayy);
    cornerElement();

    if (hinge) {
      hingeSlice();
      cornerCutout();
    }
  }
  // The hinge
  if (hinge) {
    //intersection() {
      guideHinge();
      //cornerCutout();
    //}
  }
  // TODO: use brace selector
  // Add the corner brace
  if (brace != BRACE_NONE) {
    difference() {
      color("gray")
      cornerBrace();
      glass();
    }
  }
}

module straight() {
  difference() {
    cornerElement();

    // Cut off the end. 
    // TODO: leaves a gap at the corner.
    translate([goho+O, s/2-O, 0])
    cube([s/2, s/2, 50], center=false);
    translate([-mt-gohi-s/2, s/2-mt-gohi-O, 0])
    cube([s, s/2, 50], center=false);
  }
}

// 
// Uncomment to generate the part you want
//
rotate([180,0,0])
translate([-s/2, -s/2, 0]) // center it in the workspace
echo("Rendering a left side hinge");
corner(hinge=true, brace=BRACE_LEFT);
//corner(hinge=false, brace=BRACE_BOTH);
//corner(hinge=true, brace=BRACE_NONE);
//straight();

