

procedure campaings_InitData;
var x:byte;
begin
   for x:=0 to MaxMissions do cmp_mmap[x]:=spr_c_phobos;

   cmp_mmap[0]:=spr_c_phobos;
   cmp_mmap[1]:=spr_c_phobos;
   cmp_mmap[2]:=spr_c_deimos;
   cmp_mmap[3]:=spr_c_deimos;
   cmp_mmap[4]:=spr_c_mars;
   cmp_mmap[5]:=spr_c_mars;
   cmp_mmap[6]:=spr_c_earth;
   cmp_mmap[7]:=spr_c_earth;
end;


