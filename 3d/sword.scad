$fn=100;
sigma=0.01;

blade_wiggle=0.75;
blade_w=29;
blade_t=16;
blade_h=100;
blade_tip=12;
blade_real_h=blade_h-blade_tip;
blade_sleekness=0.5;
blade_inset=10;

guard_w=80;
guard_h=28.0;

handle_w=29;
handle_h=54;

pommel_w=38;
pommel_h=38;

hilt_walls=2;
hilt_middle=18;
hilt_hang=2;
hilt_floor=2;
hilt_clasp_h=1;
hilt_clasp_wiggle=0.25;

light_w=blade_w-hilt_walls*2;
light_d=guard_h;
light_t=hilt_middle/2-hilt_floor;

button_yoff=19;
button_d=10;
button_h=8;
button_wiggle=1;
button_flange=2;
button_protrude=2;
button_remove_bottom=2;

hole_sink_d=7;
hole_screw_d=2.5;

module fcube(bs,ts,h)
{
	xoff=(bs.x-ts.x)/2;
	yoff=(bs.y-ts.y)/2;

	verts=
	[
		[0,0,0], 
		[bs.x,0,0], 
		[bs.x,bs.y,0], 
		[0,bs.y,0], 
		[xoff,yoff,h], 
		[xoff+ts.x,yoff,h], 
		[xoff+ts.x,yoff+ts.y,h], 
		[xoff,yoff+ts.y,h]
	];

	faces=
	[
		[0,1,2,3],
		[4,5,1,0],
		[7,6,5,4],
		[5,6,2,1],
		[6,7,3,2],
		[7,4,0,3]
	];

	polyhedron(verts,faces);
}

module blade()
{
	real_blade_w=blade_w-blade_wiggle;
	real_blade_t=blade_t-blade_wiggle;
	
	cube([real_blade_w,real_blade_t,blade_inset]);

	bs=[real_blade_w,real_blade_t];
	ts=[real_blade_w*blade_sleekness,real_blade_t*blade_sleekness];
	translate([0,0,blade_inset])
		fcube(bs=bs,ts=ts,h=blade_real_h-blade_inset);
	
	verts=
	[
		[ts.x,ts.y,0],
		[ts.x,0,0],
		[0,0,0],
		[0,ts.y,0],
		[ts.x/2,ts.y/2,blade_tip]
	];

	faces=
	[
		[0,1,4],
		[1,2,4],
		[2,3,4],
		[3,0,4],
		[1,0,3],
		[2,1,3]
	];
  
	translate([(bs.x-ts.x)/2,(bs.y-ts.y)/2,blade_real_h])
		polyhedron(verts,faces);
}

module guard_2d(sink,holes)
{
	difference()
	{
		polygon([[-guard_w/2,guard_h/2],[0,-guard_h/2],[guard_w/2,guard_h/2]]);
		translate([guard_w/4,guard_h/4])
		{
			if(sink)
				circle(d=hole_sink_d);
			if(holes)
				circle(d=hole_screw_d);
		}
		translate([-guard_w/4,guard_h/4])
		{
			if(sink)
				circle(d=hole_sink_d);
			if(holes)
				circle(d=hole_screw_d);
		}
	}
}

module handle_2d()
{
	h=handle_h-hole_screw_d/2;
	translate([0,hole_screw_d/2])
		polygon([[-handle_w/2,h/2],[handle_w/2,h/2],[handle_w/2,-h/2],[-handle_w/2,-h/2]]);
}

module pommel_2d(sink,holes)
{
	difference()
	{
		polygon([[-pommel_w/2,0],[0,pommel_h/2],[pommel_w/2,0],[0,-pommel_h/2]]);
		if(sink)
			circle(d=hole_sink_d);
		if(holes)
			circle(d=hole_screw_d);
	}
}

module blade_inset_2d()
{
	polygon([[-blade_w/2,blade_inset/2],[blade_w/2,blade_inset/2],[blade_w/2,-blade_inset/2],[-blade_w/2,-blade_inset/2]]);
}

module hilt_2d(hide_mid,blade,sink,holes)
{
	translate([0,-guard_h/2])
	{
		difference()
		{
			guard_2d(sink,holes);
			if(blade)
				translate([0,(guard_h-blade_inset)/2])
					blade_inset_2d();
		}
		translate([0,-handle_h/2])
		{
			if(!hide_mid)
				handle_2d(sink,holes);
			translate([0,-handle_h/2])
				pommel_2d(sink,holes);
		}
	}
}

module hilt_level(height,hide_mid,solid,blade,sink,holes)
{
	linear_extrude(height)
		difference()
		{
			hilt_2d(hide_mid,blade,sink,holes);
			if(!solid)
				offset(-hilt_walls)
					hilt_2d(hide_mid,blade,sink,holes);
		}
}

module hilt_clasp(inside)
{
	linear_extrude(hilt_clasp_h)
		if(!inside)
			difference()
			{
				offset((-hilt_clasp_wiggle-hilt_walls)/2)
					hilt_2d(false,true,false,false);
				offset(-hilt_walls)
					hilt_2d(false,true,false,false);
			}
		else
			difference()
			{
				offset(0)
					hilt_2d(false,true,false,false);
				offset((hilt_clasp_wiggle-hilt_walls)/2)
					hilt_2d(false,true,false,false);
			}
}

module hilt_half(holes)
{
	difference()
	{
		union()
		{
			hilt_level(hilt_hang,true,true,false,holes&&true,holes&&false);
			translate([0,0,hilt_hang])
			{
				hilt_level(hilt_floor,false,true,true,holes&&false,holes&&true);
				middle_real_height=hilt_middle/2-hilt_clasp_h;
				hilt_level(middle_real_height,false,false,true,false,true);
				translate([0,0,middle_real_height])
					hilt_clasp(holes);
			}
		}
		
		union()
		{
			translate([-light_w/2,sigma-light_d,hilt_hang+hilt_floor+sigma])
				cube([light_w,light_d,light_t]);

			if(!holes)
				translate([0,-button_yoff,-sigma])
					cylinder(h=hilt_hang+hilt_middle/2,d=button_d);
		}
	}
}

module button()
{
    difference()
    {
        union()
        {
            roundness=8;
            translate([0,0,roundness/2])
                minkowski()
                {
                    cylinder(h=button_h+button_protrude-roundness,d=button_d-button_wiggle-roundness);
                    sphere(d=roundness);
                }
            cylinder(h=button_h-hilt_hang-hilt_floor,d=button_d+button_flange);
        }
        translate([0,0,-sigma])
            cylinder(h=button_remove_bottom+sigma,d=button_d+button_flange+sigma);
    }
}

spread=12;

translate([-(guard_w+spread+button_d)/2,0,0])
	button();

rotate([270,0,0])
	translate([-blade_w/2,-blade_t-hilt_hang,-blade_inset])
			blade();

hilt_half(true);

translate([-(guard_w+spread+button_d),0,0])
	hilt_half();