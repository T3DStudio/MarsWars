

procedure gfx_LoadTMWTextureList(MWTextureList:PTMWTextureList;MWTextureList_n:pinteger;fname:shortstring;transparent00:boolean;letSDLSurface:boolean=false);
var
tmpMWtext:pTMWTexture;
        i:integer;
procedure next;begin MWTextureList_n^+=1;setlength(MWTextureList^,MWTextureList_n^);MWTextureList^[MWTextureList_n^-1]:=tmpMWtext;end;
begin
   MWTextureList_n^:=0;
   i:=0;
   while true do
   begin
      tmpMWtext:=gfx_MWTextureLoad(fname+i2s(i),transparent00,false,letSDLSurface);
      if(tmpMWtext=ptex_dummy)then break;
      next;
      i+=1;
   end;

   if(MWTextureList_n^=0)then
   begin
      tmpMWtext:=ptex_dummy;
      next;
      writeLog('gfx_LoadTMWTextureList: '+fname);
   end;
end;

function gfx_SDLTexture2Color():TMWColor;
begin

end;
// theme_all_terrain_mmcolor

procedure IntListAdd(intList:PTIntList;intListN:pinteger;value:integer);
begin
   intListN^+=1;
   setlength(intList^,intListN^);
   intList^[intListN^-1]:=value;
end;

procedure Str2IntList(intString:shortstring;intList:PTIntList;intListN:pinteger);
var p,l:integer;
    v,u:shortstring;
begin
   intListN^:=0;
   setlength(intList^,intListN^);

   l:=length(intString);
   while(l>0)do
   begin
      v:='';
      p:=pos(',',intString);
      if(p>0)then
      begin
         v:=copy(intString,1,p-1);
         delete(intString,1,p);
      end
      else
      begin
         v:=intString;
         delete(intString,1,l);
      end;

      while true do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      if(length(v)>0)then
      begin
         p:=pos('_',v);
         if(p>0)then
         begin
            u:=copy(v,1,p-1);
            delete(v,1,p);
            if(length(u)>0)and(length(v)>0)then
            begin
               p:=s2i(u);
               l:=s2i(v);
               while (true) do
               begin
                  IntListAdd(intList,intListN,p);
                  if(p=l)
                  then break
                  else p+=sign(l-p);
               end;
            end;
         end
         else IntListAdd(intList,intListN,s2i(v));
      end;

      l:=length(intString);
   end;
end;

procedure DecorationAnim(atime:integer;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
i,o1,o2:integer;
procedure SetPramas(oid1,oid2:integer);
begin
   if(oid1<0)or(theme_all_decor_n<=oid1)
   or(oid2<0)or(theme_all_decor_n<=oid2)then exit;

   with theme_anm_decors[oid1] do
   begin
      tda_anext:=oid2;
      tda_atime:=atime;
   end;
end;
begin
   Str2IntList(intString,@tmp_il,@tmp_iln);

   if(tmp_iln>0)then
     for i:=0 to tmp_iln-1 do
     begin
        o1:=tmp_il[i];
        o2:=tmp_il[(i+1) mod tmp_iln];
        SetPramas(o1,o2);
     end;
end;
procedure DecorationData(axo,ayo,ashadow:integer;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
i,o    :integer;
procedure SetPramas(oid:integer);
begin
   if(0<=oid)and(oid<theme_all_decor_n)then
     with theme_anm_decors[oid] do
     begin
        if(axo    <>NOTSET)then tda_xo     :=axo;
        if(ayo    <>NOTSET)then tda_yo     :=ayo;
        if(ashadow<>NOTSET)then tda_shadow :=ashadow;
     end;
end;
begin
   if(theme_all_decor_n>0)then
     if(intString<>'all')then
     begin
        Str2IntList(intString,@tmp_il,@tmp_iln);

        if(tmp_iln>0)then
          for i:=0 to tmp_iln-1 do
            SetPramas(tmp_il[i]);
     end
     else
       for o:=0 to theme_all_decor_n-1 do SetPramas(o);
end;

procedure SetTerrainsTAS(tas,tasPeriod:byte;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
o      :integer;
procedure SetParams(id:integer);
begin
   if(id<0)or(theme_all_terrain_n<=id)then exit;

   theme_all_terrain_tas      [id]:=tas;
   theme_all_terrain_tasPeriod[id]:=tasPeriod;
end;
begin
   if(theme_all_terrain_n>0)then
     if(intString<>'all')then
     begin
        Str2IntList(intString,@tmp_il,@tmp_iln);

        if(tmp_iln>0)then
          for o:=0 to tmp_iln-1 do SetParams(tmp_il[o]);
     end
     else
       for o:=0 to theme_all_terrain_n-1 do SetParams(o);
end;

procedure InitThemes;
var o:integer;
begin
   // load graph
   gfx_LoadTMWTextureList(@theme_all_decal_l  ,@theme_all_decal_n  ,'map\decals\adt'  ,true );     //writeln('decal ',theme_all_decal_n);
   gfx_LoadTMWTextureList(@theme_all_decor_l  ,@theme_all_decor_n  ,'map\decors\dec_' ,true );     //writeln('decors ',theme_all_decor_n);
   gfx_LoadTMWTextureList(@theme_all_terrain_l,@theme_all_terrain_n,'map\terrains\ter',false,true);//writeln('terrains ',theme_all_terrain_n);

   // animation and effects
   setlength(theme_anm_decors  ,theme_all_decor_n );


   // SHADOW
   DecorationData(NOTSET,NOTSET,1     ,'0_53'          );
   DecorationData(NOTSET,NOTSET,-32000,'24_27,54_120'  );

   // X Y offset
   DecorationData(NOTSET,-3    ,NOTSET,'13,35'         );
   DecorationData(NOTSET,-4    ,NOTSET,'30,31,20,21'   );
   DecorationData(NOTSET,-5    ,NOTSET,'15_17,39,41'   );
   DecorationData(NOTSET,-5    ,NOTSET,'15_17,39,41'   );
   DecorationData(NOTSET,-8    ,NOTSET,'1,2,6,13,24_27');
   DecorationData(NOTSET,-10   ,NOTSET,'34,36,29'      );
   DecorationData(NOTSET,-14   ,NOTSET,'3'             );
   DecorationData(NOTSET,-18   ,NOTSET,'7_12,18'       );
   DecorationData(12    ,-18   ,NOTSET,'5,11'          );

   DecorationData(NOTSET,-20   ,NOTSET,'32'            );
   DecorationData(NOTSET,-21   ,NOTSET,'19'            );
   DecorationData(5     ,-22   ,NOTSET,'33'            );

   DecorationData(5     ,-22   ,NOTSET,'33'            );

   DecorationData(NOTSET,-9    ,NOTSET,'52,22'         );
   DecorationData(NOTSET,-8    ,NOTSET,'53,23'         );
   DecorationData(4     ,-8    ,NOTSET,'48_50'         );
   DecorationData(0     ,-17   ,NOTSET,'42_47'         );

   DecorationAnim(-1  ,'51,14');
   DecorationAnim(-6  ,'52,22');
   DecorationAnim(-5  ,'53,23');
   DecorationAnim(15  ,'48_50');
   DecorationAnim(15  ,'43,42');
   DecorationAnim(15  ,'44,45');
   DecorationAnim(15  ,'46,47');

   DecorationAnim(20  ,'76,80');
   DecorationAnim(20  ,'78,94');
   DecorationAnim(20  ,'79,95');
   DecorationAnim(20  ,'91,96');
   DecorationAnim(20  ,'92,97');
   DecorationAnim(20  ,'93,102');
   DecorationAnim(20  ,'114,115');
   DecorationAnim(20  ,'113,116');

   DecorationAnim(20  ,'54,60');
   DecorationAnim(20  ,'57,67');
   DecorationAnim(20  ,'59,68');
   DecorationAnim(20  ,'61,71');
   DecorationAnim(20  ,'62,72');
   DecorationAnim(20  ,'63,73');
   DecorationAnim(20  ,'64,74');
   DecorationAnim(20  ,'65,75');

   setlength(theme_all_terrain_mmcolor  ,theme_all_terrain_n);
   setlength(theme_all_terrain_tas      ,theme_all_terrain_n);
   setlength(theme_all_terrain_tasPeriod,theme_all_terrain_n);

   if(theme_all_terrain_n>0)then
     for o:=0 to theme_all_terrain_n-1 do
     begin
        theme_all_terrain_mmcolor  [o]:=c_white;//gfx_SDLSurfaceGetColor(theme_all_terrain_l[o].sdlSurface);
        theme_all_terrain_tas      [o]:=tas_ice;
        theme_all_terrain_tasPeriod[o]:=fr_fpsd3;
     end;

   SetTerrainsTAS(tas_liquid,25,'13,20,23,28,48,60');
   SetTerrainsTAS(tas_liquid,12,'52,53,55,71,72,73,77');
   SetTerrainsTAS(tas_magma ,25,'64,35,36,39,40,69,76,90');
end;


procedure SetThemeList(intList:PTIntList;intListN:pinteger;smax:integer;intString:shortstring);
var i,o,
tmp_iln:integer;
tmp_il :TIntList;
begin
   Str2IntList(intString,@tmp_il,@tmp_iln);

   intListN^:=0;
   setlength(intList^,intListN^);

   if(tmp_iln>0)then
     for i:=0 to tmp_iln-1 do
     begin
        o:=tmp_il[i];

        if(0<=o)and(o<smax)then IntListAdd(intList,intListN,o);
     end;
end;

procedure SetTheme(new_theme:integer);
begin
   if(new_theme<0)or(new_theme>=theme_n)then new_theme:=abs(new_theme) mod theme_n;
   theme_cur:=new_theme;
   case theme_cur of
0: begin  // UAC BASE
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'12'                           );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'0,2,5,6,7,8,9'                );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'0,2,5,6,7,8,9,11,79'          );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'13,20,48,55,71,72'            );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1_3,21,22,26,27,29,31,32'     );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'19,22_27,32,35,37_41,52_53'   );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'81_87'                        );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'56_58,65,67,75'               );

      theme_cur_crater_tes:=tes_tech;
      theme_cur_liquid_tes:=tes_tech;
   end;
1: begin  // TECH BASE
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'74'                                 );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'11,79,80,81,82,85,87,27'            );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'80,81,82,85,87,67,83,84'            );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'13,20,48,55,71,72'                  );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1_3,21,22,26,27,29,31,32'           );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'19,22_27,32,35,37_41,30,48'         );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'81_87'                              );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'56_58,65,67,75'                     );

      theme_cur_crater_tes:=tes_tech;
      theme_cur_liquid_tes:=tes_nature;
   end;
2: begin  // UNKNOWN PLANET
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'12,18,19,74'                          );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'4,5,8,10,16,17,24,25,26,30,31,32,33'  );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'34,37,38,41,42,43,44,45,46,47,51,56'  );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'13,20,23,28,40,48,52,53,55,64,73,71'  );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4_6,8_17,23_25'                     );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'0_12,18,28,48_50'                     );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'77,88_92,96_101'                      );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,58,66,69,70'                       );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
3: begin  // UNKNOWN MOON
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'12,74'                                 );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'34,37,38,41,42,43,44,45,46,47,51'      );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'57,59,61,62,63,65,66,68,70,78,89,14,15');
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'13,20,23,28,40,48,52,53,55,64,73,71'   );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4_6,8_17,23_25'                      );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'0_12,18,28_32,48_50'                   );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'77,88_92,96_101,33,34'                 );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,58,66,69,70'                        );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
4: begin  // CAVES
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'18,19'                                       );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'57,59,61,62,65,66,68,70,78,88,91'            );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'4,5,8,10,16,17,24,25,26,30,31,32,33,14,15,54');
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'13,20,23,28,40,48,52,53,55,64,73,60,71'      );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4_6,8_20,23_25,28,30,33,34'                );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'0_13,15_28,35,36,42_47,48'                   );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'77,88_92,96_101'                             );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,58,66,69,70'                              );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
5: begin  // ICE CAVES
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'18,19'                                                         );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'16,17,24,25,26,30,31,37,38,41,42,44,45,58,59,61,62,65,91'      );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'16,17,24,25,26,30,31,37,38,41,42,44,45,58,59,61,62,65,14,15,54');
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'75'                            );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1_20,23_25,28,30,33,34'        );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'0_13,15_28,35,36,42_47,48'     );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'77,88_92,96_101'               );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,56,58,66,69,70'             );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
6: begin  // HELL
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'18,19,1'             );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'49'                  );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'29,35,36,39,40'      );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'23,35,36,39,40,69,76,77,90'           );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4,9,15,18_20,23_25,28,30,33,34'     );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'3,13_17,20,21,36,42_47,112'           );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'76,78_80,93_95,102,103_105,107_111,113,114');
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'54,59_64,68,71_74,117_120'                 );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
7: begin  // HELL CAVES
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'18,19,1'             );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'38,56,63,66,88'      );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'14,15,29,38,51'      );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'23,28,35,36,39,40,69,76,77,60'        );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4,9,15,18_20,23_25,28,30,33,34'     );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'3,13_17,20,21,36,42_47,106,112'       );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'77,88_92,96_101,103_105,107_111,113,114');
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,66,69,70,117_120'                    );

      theme_cur_crater_tes:=tes_nature;
      theme_cur_liquid_tes:=tes_nature;
   end;
8: begin  // HELL CITY
      SetThemeList(@theme_cur_teleport_l,@theme_cur_teleport_n,theme_all_terrain_n,'18,19,1'              );
      SetThemeList(@theme_cur_terrain_l ,@theme_cur_terrain_n ,theme_all_terrain_n,'50,86,89,92'          );
      SetThemeList(@theme_cur_crater_l  ,@theme_cur_crater_n  ,theme_all_terrain_n,'50,86,89,92,14,15,29,38,68'           );
      SetThemeList(@theme_cur_liquid_l  ,@theme_cur_liquid_n  ,theme_all_terrain_n,'23,28,35,36,39,40,60,69,76,77,90'     );

      SetThemeList(@theme_cur_decal_l   ,@theme_cur_decal_n   ,theme_all_decal_n  ,'1,4,9,15,18_20,23_25,28,30,33,34'     );

      SetThemeList(@theme_cur_decor_l   ,@theme_cur_decor_n   ,theme_all_decor_n  ,'3,13_17,20,21,36,42_47,106,112'       );
      SetThemeList(@theme_cur_1rock_l   ,@theme_cur_1rock_n   ,theme_all_decor_n  ,'103_105,107_111,113,114'              );
      SetThemeList(@theme_cur_2rock_l   ,@theme_cur_2rock_n   ,theme_all_decor_n  ,'55,66,69,70,117_120'                  );

      theme_cur_crater_tes:=tes_tech;
      theme_cur_liquid_tes:=tes_nature;
   end;
   end;
end;




