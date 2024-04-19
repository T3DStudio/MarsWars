

procedure campaings_InitData;
var x:byte;
begin
   for x:=0 to MaxMissions do campain_mmap[x]:=spr_c_phobos;

   campain_mmap[0]:=spr_c_phobos;
   campain_mmap[1]:=spr_c_phobos;
   campain_mmap[2]:=spr_c_deimos;
   campain_mmap[3]:=spr_c_deimos;
   campain_mmap[4]:=spr_c_mars;
   campain_mmap[5]:=spr_c_mars;
   campain_mmap[6]:=spr_c_earth;
   campain_mmap[7]:=spr_c_earth;
end;


