

function MakeReflectedSurface(sourceSurface:PSDL_Surface;xa,ya,transparent:boolean):PSDL_Surface;
var x,y,sx,sy:integer;
    c:cardinal;
begin
   MakeReflectedSurface:=gfx_SDLSurfaceCreate(sourceSurface^.w,sourceSurface^.h);
   for x:=1 to sourceSurface^.w do
    for y:=1 to sourceSurface^.h do
    begin
       if(xa)then sx:=sourceSurface^.w-x else sx:=x-1;
       if(ya)then sy:=sourceSurface^.h-y else sy:=y-1;
       c:=SDL_GETpixel(sourceSurface,x-1,y-1);

       SDL_SETpixel(MakeReflectedSurface,sx,sy,c);
    end;
   if(transparent)then SDL_SetColorKey(MakeReflectedSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(MakeReflectedSurface,0,0));
end;

procedure LoadTMWTextureList(MWTextureList:PTMWTextureList;MWTextureList_n:pinteger;fname:shortstring;addReflected:boolean);
var t:TMWTexture;
    i:integer;
procedure next;begin MWTextureList_n^+=1;setlength(MWTextureList^,MWTextureList_n^);MWTextureList^[MWTextureList_n^-1]:=t;end;
begin
   MWTextureList_n^:=0;
   i:=0;
   while true do
   begin
      with t do
      begin
         sdlSurface:=gfx_SDLSurfaceLoad(fname+i2s(i),false,false);
         if(sdlSurface=r_empty)then break;
         w :=sdlSurface^.w;
         h :=sdlSurface^.h;
         hw:=sdlSurface^.w div 2;
         hh:=sdlSurface^.h div 2;
      end;
      next;

      if(addReflected)then
      begin
         with t do sdlSurface:=MakeReflectedSurface(sdlSurface,true,false,false);
         next;
      end;

      i+=1;
   end;

   if(MWTextureList_n^=0)then
   begin
      t:=spr_dummy;
      next;
   end;
end;

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

procedure gfx_MWTextureSetTransparent(spr:PTMWTexture;xa:boolean);
begin
   with spr^ do
    if(xa)
    then SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,w-1,0))
    else SDL_SetColorKey(sdlSurface,SDL_SRCCOLORKEY+SDL_RLEACCEL,sdl_getpixel(sdlSurface,0  ,0));
end;

procedure ThemeSetTransparent(SpriteList:pTMWTextureList;SpriteListN:integer;intString:shortstring);
var i,o,
intListN:integer;
intList :TIntList;
begin
   if(intString<>'all')then
   begin
      Str2IntList(intString,@intList,@intListN);

      if(intListN>0)then
        for i:=0 to intListN-1 do
        begin
           o:=intList[i]*2;
           if(o<=0)and(o<SpriteListN)then
           begin
              gfx_MWTextureSetTransparent( @(SpriteList^[o  ]), ( o    mod 2)=1);
              gfx_MWTextureSetTransparent( @(SpriteList^[o+1]), ((o+1) mod 2)=1);
           end;
        end;
   end
   else
     if(SpriteListN>0)then
       for o:=0 to SpriteListN-1 do gfx_MWTextureSetTransparent( @(SpriteList^[o]), (o mod 2)=1 );
end;

procedure DecAnim(l:PTThemeDecorAnimL;it:pinteger;intString:shortstring;_at,_an,_xo,_yo,_sh,_dp:integer);
var i,o,
tmp_intListN:integer;
tmp_intList :TIntList;
procedure SetDecAnim(p:integer;xa:boolean);
begin
   with l^[p] do
   begin
      tda_atime:=_at;
      if(xa)then
      begin
         tda_anext:=_an*2+1;
         tda_xo   :=-_xo;
      end
      else
      begin
         tda_anext:=_an*2;
         tda_xo   :=_xo;
      end;
      tda_yo   :=_yo;
      tda_sh   :=_sh;
      tda_depth:=_dp;
   end;
end;
begin
   Str2IntList(intString,@tmp_intList,@tmp_intListN);

   for i:=1 to tmp_intListN do
   begin
      o:=tmp_intList[i-1]*2;
      if(0<=o)and(o<it^)then
      begin
         SetDecAnim(o  ,false);
         SetDecAnim(o+1,true );
      end;
   end;
end;

procedure SetTerrainsTAS(tas,tasPeriod:byte;intString:shortstring);
var
tmp_il :TIntList;
tmp_iln,
o      :integer;
begin
   if(intString<>'all')then
   begin
      Str2IntList(intString,@tmp_il,@tmp_iln);

      if(tmp_iln>0)then
        for o:=0 to tmp_iln-1 do
          if(0<=tmp_il[o])and(tmp_il[o]<theme_all_terrain_n)then
          begin
             theme_all_terrain_tas      [tmp_il[o]]:=tas;
             theme_all_terrain_tasPeriod[tmp_il[o]]:=tasPeriod;
          end;
   end
   else
     if(theme_all_terrain_n>0)then
       for o:=0 to theme_all_terrain_n-1 do
       begin
          theme_all_terrain_tas      [o]:=tas;
          theme_all_terrain_tasPeriod[o]:=tasPeriod;
       end;
end;

procedure InitThemes;
var o:integer;
begin
   // load graph
   LoadTMWTextureList(@theme_all_decal_l  ,@theme_all_decal_n  ,str_f_map+'decals\adt'  ,true );
   LoadTMWTextureList(@theme_all_decor_l  ,@theme_all_decor_n  ,str_f_map+'decors\dec_' ,true );
   LoadTMWTextureList(@theme_all_terrain_l,@theme_all_terrain_n,str_f_map+'terrains\ter',false);

   // transparent

   ThemeSetTransparent(@theme_all_decal_l,theme_all_decal_n,'0_20,23_34');
   ThemeSetTransparent(@theme_all_decor_l,theme_all_decor_n,'all');

   // animation and effects
   setlength(theme_anm_decors  ,theme_all_decor_n );

   {// shadow
   for o:=1 to theme_all_decor_n do begin FillChar(theme_anm_decors[o-1],SizeOf(theme_anm_decors[o-1]),0);with theme_anm_decors[o-1] do begin sh:=1;               end;end;
   for o:=1 to theme_all_srock_n do begin FillChar(theme_anm_srocks[o-1],SizeOf(theme_anm_srocks[o-1]),0);with theme_anm_srocks[o-1] do begin sh:=-32000;depth:=0; end;end;
   for o:=1 to theme_all_brock_n do begin FillChar(theme_anm_brocks[o-1],SizeOf(theme_anm_brocks[o-1]),0);with theme_anm_brocks[o-1] do begin sh:=-32000;depth:=0; end;end;

   //    DECORS
   //                                           ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'13,35'   ,0  ,0  ,0  ,-3  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'30,31,20,21'
                                                          ,0  ,0  ,0  ,-4  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'15_17,39,41'
                                                          ,0  ,0  ,0  ,-5  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'1,2,6,13'
                                                          ,0  ,0  ,0  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'24_27'   ,0  ,0  ,0  ,-8  ,-32000 ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'34,36,29',0  ,0  ,0  ,-10 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'3'       ,0  ,0  ,0  ,-14 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'7_12,18' ,0  ,0  ,0  ,-18 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'5,11'    ,0  ,0  ,12 ,-18 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'32'      ,0  ,0  ,0  ,-20 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'19'      ,0  ,0  ,0  ,-21 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'33'      ,0  ,0  ,5  ,-22 ,1      ,0);

   // Anims
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'14'      ,-1 ,51 ,0  , 0  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'51'      ,-1 ,14 ,0  , 0  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'22'      ,-6 ,52 ,0  ,-9  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'52'      ,-2 ,22 ,0  ,-9  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'23'      ,-5 ,53 ,0  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'53'      ,-2 ,23 ,0  ,-8  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'48'      ,15 ,49 ,4  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'49'      ,15 ,50 ,4  ,-8  ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'50'      ,15 ,48 ,4  ,-8  ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'42'      ,15 ,43 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'43'      ,15 ,42 ,0  ,-17 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'44'      ,15 ,45 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'45'      ,15 ,44 ,0  ,-17 ,1      ,0);

   DecAnim(@theme_anm_decors,@theme_all_decor_n,'46'      ,15 ,47 ,0  ,-17 ,1      ,0);
   DecAnim(@theme_anm_decors,@theme_all_decor_n,'47'      ,15 ,46 ,0  ,-17 ,1      ,0);


   // S ROCKS                                  ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'3'       ,20 ,22 ,0  ,0   ,-32000 ,0); // rock with pool 1
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'22'      ,20 ,3  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'4'       ,20 ,23 ,0  ,0   ,-32000 ,0); // rock with pool 2
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'23'      ,20 ,4  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'9'       ,-1 ,24 ,0  ,0   ,-32000 ,0); // hell rocks 1
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'24'      ,-1 ,9  ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'10'      ,-1 ,25 ,0  ,0   ,-32000 ,0); // hell rocks 2
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'25'      ,-1 ,10 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'11'      ,-1 ,26 ,0  ,0   ,-32000 ,0); // hell rocks 3
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'26'      ,-1 ,11 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'12'      ,-1 ,0  ,0  ,0   ,-32000 ,0); // hell rocks 4
   DecAnim(@theme_anm_srocks,@theme_all_srock_n,'0'       ,-1 ,12 ,0  ,0   ,-32000 ,0);


   // B ROCKS                                  ns         atm ana xo  yo   shadow  depth
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'9'       ,-1 ,19 ,0  ,0   ,-32000 ,0); // tech slime canister
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'19'      ,-1 , 9 ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'11'      ,-1 ,20 ,0  ,0   ,-32000 ,0); // tech water canister
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'20'      ,-1 ,11 ,0  ,0   ,-32000 ,0);

   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'5'       ,-1 ,15 ,0  ,0   ,-32000 ,0); // hell rocks 1
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'15'      ,-1 ,5  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'6'       ,-1 ,16 ,0  ,0   ,-32000 ,0); // hell rocks 2
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'16'      ,-1 ,6  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'7'       ,-1 ,17 ,0  ,0   ,-32000 ,0); // hell rocks 3
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'17'      ,-1 ,7  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'8'       ,-1 ,18 ,0  ,0   ,-32000 ,0); // hell rocks 4
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'18'      ,-1 ,8  ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'13'      ,-1 ,21 ,0  ,0   ,-32000 ,0); // hell rocks 5
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'21'      ,-1 ,13 ,0  ,0   ,-32000 ,0);
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'14'      ,-1 ,0  ,0  ,0   ,-32000 ,0); // hell rocks 6
   DecAnim(@theme_anm_brocks,@theme_all_brock_n,'0'       ,-1 ,14 ,0  ,0   ,-32000 ,0);    }

   setlength(theme_all_terrain_mmcolor  ,theme_all_terrain_n);
   setlength(theme_all_terrain_tas      ,theme_all_terrain_n);
   setlength(theme_all_terrain_tasPeriod,theme_all_terrain_n);

   if(theme_all_terrain_n>0)then
     for o:=0 to theme_all_terrain_n-1 do
     begin
        theme_all_terrain_mmcolor  [o]:=gfx_SDLSurfaceGetColor(theme_all_terrain_l[o].sdlSurface);
        theme_all_terrain_tas      [o]:=tas_ice;
        theme_all_terrain_tasPeriod[o]:=fr_fpsd3;
     end;

   SetTerrainsTAS(tas_liquid,30,'13,20,23,28,48');
   SetTerrainsTAS(tas_liquid,15,'52,53,60,71,72,73,77');
end;


procedure SetThemeList(intList:PTIntList;intListN:pinteger;smax:integer;addReflected:boolean;intString:shortstring);
var i,o,
tmp_iln:integer;
tmp_il :TIntList;
begin
   Str2IntList(intString,@tmp_il,@tmp_iln);

   intListN^:=0;
   setlength(intList^,intListN^);

   for i:=1 to tmp_iln do
   begin
      o:=tmp_il[i-1];
      if(o>=0)then
      begin
         if(addReflected)then
         begin
            o:=o*2;
            if(o<smax)then
            begin
               IntListAdd(intList,intListN,o  );
               IntListAdd(intList,intListN,o+1);
            end;
         end
         else
           if(o<smax)then IntListAdd(intList,intListN,o);
      end
      else IntListAdd(intList,intListN,o);
   end;
end;

procedure SetTerrainIDs(new_terrain,new_crater,new_liquid:integer);
var t:integer;
begin
   if(theme_cur_terrain_n<=0)then theme_cur_tile_terrain_id:=-1 else begin if(new_terrain<0)then t:=abs(new_terrain) mod theme_cur_terrain_n else t:=min2i(theme_cur_terrain_n-1,new_terrain);theme_cur_tile_terrain_id:=theme_cur_terrain_l[t];end;
   if(theme_cur_crater_n <=0)then theme_cur_tile_crater_id :=-1 else begin if(new_crater <0)then t:=abs(new_crater ) mod theme_cur_crater_n  else t:=min2i(theme_cur_crater_n -1,new_crater );theme_cur_tile_crater_id :=theme_cur_crater_l [t];end;
   if(theme_cur_liquid_n <=0)then theme_cur_tile_liquid_id :=-1 else begin if(new_liquid <0)then t:=abs(new_liquid ) mod theme_cur_liquid_n  else t:=min2i(theme_cur_liquid_n -1,new_liquid );theme_cur_tile_liquid_id :=theme_cur_liquid_l [t];end;

   if(theme_cur_tile_terrain_id>0)then
   begin
      theme_cur_liquid_mmcolor  :=theme_all_terrain_mmcolor  [theme_cur_tile_terrain_id];
      theme_cur_liquid_tas      :=theme_all_terrain_tas      [theme_cur_tile_terrain_id];
      theme_cur_liquid_tasPeriod:=theme_all_terrain_tasPeriod[theme_cur_tile_terrain_id];
   end
   else
   begin
      theme_cur_liquid_mmcolor  :=c_white;
      theme_cur_liquid_tas      :=tas_ice;
      theme_cur_liquid_tasPeriod:=fr_fpsd2;
   end;
end;

procedure SetTheme(new_theme:integer);
begin
   if(new_theme<0)or(new_theme>=theme_n)then new_theme:=abs(new_theme) mod theme_n;
   theme_cur:=new_theme;
   case theme_cur of
   0: begin  // TECH BASE
         SetThemeList(@theme_cur_terrain_l,@theme_cur_terrain_n,theme_all_terrain_n,false,'0,2,7,9,'                );
         SetThemeList(@theme_cur_crater_l ,@theme_cur_crater_n ,theme_all_terrain_n,false,'0,7,8,11,67'             );
         SetThemeList(@theme_cur_liquid_l ,@theme_cur_liquid_n ,theme_all_terrain_n,false,'13,20,48,55,71,72'       );
         SetThemeList(@theme_cur_decal_l  ,@theme_cur_decal_n  ,theme_all_decal_n  ,true ,'1_3,21,22,26,27,29,31,32');
         SetThemeList(@theme_cur_decor_l  ,@theme_cur_decor_n  ,theme_all_decor_n  ,true ,'19,22_27,29_32,35,37_41,52_53,56_58,65,67,75,81_87' );

         theme_cur_crater_tes:=tes_tech;
         theme_cur_liquid_tes:=tes_tech;
      end;
   {1: begin  // TECH BLUE BASE
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1_3,21,22,26,27,29,31,32');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'19'         );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'17,18,26'   );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'17,18,19,26');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_2,6,13_15');
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'13_19'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'9_12'       );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'19,22_27,29_32,35,37_41,52_53');

         theme_liquid_style:=1;
         theme_crater_style:=1;
      end;

   2: begin  // PLANET
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_17,23_25');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_16,20_25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_15'           );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,20,21'      );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_12,18,28_29,36,48_50 ');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   3: begin  // PLANET MOON
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_17,23_25'       );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2_4,8,10_13,20_23,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0,4,6,8,9,11,14'          );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,20,21'   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'         );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_12,29_34 ' );

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   4: begin  // CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4_20,23_25,28,30,33,34'   );
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0_4,8_16,20_25'   );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0_4,8_16,20_25,28_30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'0_14'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8,13,14,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4,12'           );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_22,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   5: begin  // ICE CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'0,2,11_13,20,25');
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'0,2,11_13,20,25,28');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'16'             );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1,2,5_8,20,21'  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'            );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'0_23,28,35,36,42_47,48_50');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;

   6: begin  // HELL
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'1,27'                  );
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,8_9,11'              );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'9_12'                  );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'5_8,13,14'             );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end;
   7: begin  // HELL CAVES
         SetThemeList(@theme_decals  ,@theme_decaln  ,@theme_spr_decaln  ,'1,4,9,15,18_20,23_25,28,30,33,34');
         SetThemeList(@theme_terrains,@theme_terrainn,@theme_spr_terrainn,'4,10,14,16,21,23'      );
         SetThemeList(@theme_bliquids,@theme_bliquidn,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_craters ,@theme_cratern ,@theme_spr_terrainn,'4,10,14,16,21,23,29,30');
         SetThemeList(@theme_liquids ,@theme_liquidn ,@theme_spr_liquidn ,'4,5,8_9,11'            );
         SetThemeList(@theme_srocks  ,@theme_srockn  ,@theme_all_srock_n  ,'1_8'                   );
         SetThemeList(@theme_brocks  ,@theme_brockn  ,@theme_all_brock_n  ,'1_4'                   );
         SetThemeList(@theme_decors  ,@theme_decorn  ,@theme_all_decor_n  ,'3,13_17,20,21,36,42_47');

         theme_liquid_style:=0;
         theme_crater_style:=0;
      end; }
   end;
end;



