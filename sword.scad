bay_dim=[25,60,12];
batt_dim=[20,30,3.15];
handle_walls=2;
sigma=0.01;
details=2;
blade_inset=10;
button_d=10;
$fn=100;

handle_top=bay_dim.y+handle_walls;
mid_dim=[bay_dim.x+handle_walls*2,handle_top,bay_dim.z+handle_walls*2];
hilt_w=bay_dim.x*0.75;
outer_handle_h=bay_dim.z+handle_walls*2+details*2;
blade_w=bay_dim.x+handle_walls*2;
blade_t=bay_dim.z+handle_walls*2;
blade_h=100;
blade_tip=12;
blade_real_h=blade_h-blade_tip;
blade_sleekness=0.5;

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

module cr2032_slot()
{
    cube(size=batt_dim);
}

module bay()
{
    translate([-(bay_dim.x+handle_walls*2)/2+handle_walls,handle_walls,handle_walls])
        cube(size=bay_dim);
}

module handle()
{
    difference()
    {
        union()
        {
            translate([-mid_dim.x/2,0,0])
                cube(size=mid_dim);

            translate([0,0,-details])
                cylinder($fn=4,h=bay_dim.z+handle_walls*2+details*2,r=hilt_w);

            //(bay_dim.x-hilt_w)/2
            translate([0,handle_top-hilt_w/2,-details])
                rotate([0,0,270])
                    scale([1,2.5,1])
                        cylinder($fn=3,h=outer_handle_h,r=hilt_w);
        }

        union()
        {
            translate([-mid_dim/2,0,0])
            {
                bay();

                translate([-blade_w/2,handle_top+sigma-blade_inset,0])
                    cube([blade_w,blade_inset,blade_t]);

                translate([-batt_dim.x/2,-(hilt_w+sigma),(mid_dim.z-batt_dim.z)/2])
                    cr2032_slot();
            }

            translate([0,handle_top-blade_inset-button_d/2,handle_walls])
                cylinder(d=button_d,h=outer_handle_h-handle_walls-details+sigma);
        }
    }
}

module blade()
{
    bs=[blade_w,blade_t];
    ts=[blade_w*blade_sleekness,blade_t*blade_sleekness];
    fcube(bs=bs,ts=ts,h=blade_real_h);
    
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

handle();
//blade();