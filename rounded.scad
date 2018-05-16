
// Rounded box: radius is added outside, to each dimension
module roundedCube(size/*[x,y,z]*/, radius, center=true)
{
    width = size[0] - radius*2;
    length = size[1] - radius*2;
    height = size[2] - radius*2;

    minkowski() {
        cube(size=[width,length,height], center=center);
        sphere(r=radius, center=center);
    }
}

// A rounded rect fitting exactly width and length taking into account the radius.
// At r=w/2, r=l/2 this this is circular.
// See roundedCube for a box with corners rounded in 3 dimensions.
// size - [width,length,height]
// radius - radius of corners
//
// TODO: Would be nice to be able to control the z-dimension radius separately for making shallow rounded things.
//
module roundedRect(size, radius)
{
	x = size[0]-r;
	y = size[1]-r;
	z = size[2];

	linear_extrude(height=z)
	hull()
	{
		// place 4 circles in the corners, with the given radius
		translate([(-x/2)+(radius/2), (-y/2)+(radius/2), 0])
		circle(r=radius);
	
		translate([(x/2)-(radius/2), (-y/2)+(radius/2), 0])
		circle(r=radius);
	
		translate([(-x/2)+(radius/2), (y/2)-(radius/2), 0])
		circle(r=radius);
	
		translate([(x/2)-(radius/2), (y/2)-(radius/2), 0])
		circle(r=radius);
	}
}


