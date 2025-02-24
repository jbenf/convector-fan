use <utils.scad>

fan_width = 80;
fan_height = 25;
hole_spacing = 72;
hole_dia = 4.5;
hub_dia = 33;
grill_factor = 0.75;
grill_width = 4.5;
wall_width = 1.6;
wiggleroom = 1;
corner_radius = 2;
extra_width = 23;
off = 0;
lid_height=5;


width = fan_width + wiggleroom + 2*wall_width + 2*extra_width;
depth = fan_width + wiggleroom + 2*wall_width;

heights = [wall_width, fan_height-lid_height, lid_height+wall_width];
ofs = [ for (o = 0, i = 0;i < len(heights);o = o + heights[i],i = i + 1) o + heights[i]];

module grill2d() {
    mirror([1,0,0]) difference() {
        circle(d=fan_width-2);
        circle(d=hub_dia);
 
        for( i = [0: 90: 359] ) {
            rotate([0,0,i]) intersection() {
                translate([0,fan_width*grill_factor/2 - hub_dia/2 + grill_width]) 
                intersection() {
                    difference() {
                        circle(d=fan_width*grill_factor);
                        circle(d=fan_width*grill_factor-grill_width*2);
                    }
                    translate([0, -fan_width*grill_factor*0.5]) square([fan_width*grill_factor*0.5, fan_width*grill_factor]);
                }
                circle(d=fan_width);
            }
        }
    }

}


module fan_pins2d() {
    for(x=[-hole_spacing/2 : hole_spacing : hole_spacing/2]) {
        for(y=[-hole_spacing/2 : hole_spacing : hole_spacing/2]) {
            translate([x, y]) circle(d=hole_dia-0.5);
        }
    }
}

module bottom_case_positive(grill=true) {
    
    translate([0,0,ofs[0]]) linear_extrude(8) fan_pins2d();
    
    translate([0,0,ofs[0]]) in_all_corners([width-32, 0], mask=[0,2], rotate=true) linear_extrude(6) square([13,depth], center=true);
    translate([0,0,ofs[0]]) in_all_corners([width-32, depth-8]) linear_extrude(fan_height-lid_height) square([13,8], center=true);
    
    translate([0,0,ofs[0]]) in_all_corners([width-10, 0], mask=[0,2], rotate=true) linear_extrude(fan_height-lid_height) square([10,30], center=true);
    
    difference() {
        case([width-2*wall_width, depth-2*wall_width, fan_height+wall_width], wall=wall_width, screw_post_height=5+wall_width);
        if(grill) linear_extrude(100) grill2d();
    }
}

module bottom_case(grill=true) {
    difference() {
        bottom_case_positive(grill);
        in_all_corners([width-32, 0], mask=[0,2], rotate=true) {
            linear_extrude(4) square([6,depth], center=true);
            translate([0,0,1.5]) linear_extrude(3) square([9,depth], center=true);
        }
        in_all_corners([width-32, depth-8]) {
            linear_extrude(fan_height) square([9,3], center=true);
        }
        in_all_corners([width, 0], mask=[0,2], rotate=true) {
            connector_positive();
        }
        in_all_corners([width-12, depth-12]) {
            $fn=6;
            linear_extrude(17.1) circle(d=6.25);
        }
    }

}

module connector_positive() {
    translate([5,0,21]) rotate([0,90,0]) rounded_cube([20,20,10], center=true, flat=true);
    hull() {
        translate([7,0,21]) rotate([0,90,0]) rounded_cube([20,20,1], center=true, flat=true);
        translate([11,0,21]) rotate([0,90,0]) rounded_cube([25,25,1], center=true, flat=true);
    }
}

module connector(width=0) {
    difference() {
        union() {
            intersection() {
                union(){
                    translate([width/2,0,0]) connector_positive();
                    mirror([1,0,0]) translate([width/2,0,0]) connector_positive();
                }
                cube([100,100,53.2], center=true);
            }
            translate([0,0,20]) rotate([0,90,0]) rounded_cube([20,22,width], flat=true, center=true);
        }
        translate([0,0,20]) rotate([0,90,0]) {
            rounded_cube([14,16,300], flat=true, center=true);
            translate([-4,0,0]) rounded_cube([8,16,300], flat=true, center=true, r=1);
        }
    }
}



module top_case_positive() {
    translate([0,0,ofs[1]-wall_width]) linear_extrude(8) fan_pins2d();
    
    difference() {
        case([width-2*wall_width, depth-2*wall_width, fan_height+wall_width], wall=wall_width, screw_post_height=5+wall_width, lid=true);
        linear_extrude(1000) grill2d();
    }
}

module top_case() {
    difference() {
        top_case_positive();
        in_all_corners([width-32, depth-8]) {
            linear_extrude(100) square([10,4], center=true);
        }
    }
}



module cap() {
    intersection() {
        difference() {
            union(){
                connector_positive();
                translate([-wall_width/2,0,21]) rotate([0,90,0]) rounded_cube([22,22,wall_width], flat=true, center=true);
            }
        }
        cube([100,100,53.2], center=true);
    }
    translate([-wall_width/2,0,27.4]) cube([wall_width, 22,wall_width], center=true);
}

module esp8266_case() {
    difference() {
        union() {
            case([depth, depth-2*wall_width, fan_height], lid_height=5, wall=wall_width);
            translate([0,0,ofs[0]]) in_all_corners([depth+wall_width-10, 0], mask=[2], rotate=true) linear_extrude(fan_height-lid_height) square([10,30], center=true);
            
        }
        in_all_corners([depth+wall_width*2, 0], mask=[2], rotate=true) {
            connector_positive();
        }
        translate([-depth/2,0,fan_height/2]) rotate([0,90,0]) cylinder(d=12.5, h=50, center=true);
        translate([-depth/2,20,fan_height/2]) rotate([0,90,0]) cylinder(d=8, h=50, center=true);
        translate([-depth/2,-20,fan_height/2]) cube([50, 7, 4], center=true);
    }
    
    translate([0,0,50]) difference() {
        color("red") case([depth, depth-2*wall_width, fan_height], lid_height=7, wall=wall_width, lid=true);
        translate([depth/2,0,fan_height-5+wall_width]) cube([30,21,10], center=true);
    }
}


module magnet_holder(d=8, h=3, o=-0.4) {
    linear_extrude(depth*0.4) offset(o) {
        square([6,4], center=true);
        translate([0,1.5]) square([9,3],center=true);
    }
    
    linear_extrude(h-1) {
        difference() {
            union() {
                translate([0,-d]) circle(d=d+4);
                translate([0,-d/4]) offset(o) square([6,d/2], center=true);
            }
            translate([0,-d]) circle(d=d);
        }
    }
    
}


$fn=60;

bottom_case();


translate([0,0,50]) color("red") top_case();

translate([-width/2,0,30]) color("white") connector();

translate([-width/2-50,0,30]) color("white") connector(30);

translate([width/2,0,30]) rotate([0,0,180]) color("white") cap();

translate([width/2,0,80]) rotate([0,0,180]) color("white") difference() {
    cap();
    translate([0,0,19]) rotate([0,90,0]) cylinder(d=8, h=30, center=true);
    translate([17,0,19]) rotate([0,90,0]) cylinder(d=12.5, h=30, center=true, $fn=6);
    translate([12,0,20]) cube([15,15,17], center=true);
}

translate([-150, 0, 0]) esp8266_case();

translate([0,-100,0]) magnet_holder();

