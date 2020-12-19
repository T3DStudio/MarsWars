
{$include missions\m1.pas}


{if(uid=UID_Portal)and(buff[ub_advanced]>0)and(rld=0)then
begin
   repeat
      inc(utrain,1);
      utrain:=utrain mod 32;
      if(g_addon=false)and(utrain>6)then continue;
   until (_cmp_untCndt(rld_a,utrain)=false)or(utrain=31);

   if(utrain<31)then
   begin
      _lcu:=0;

      case g_mode of
        gm_coop: if(random(2)=0)
                 then rld:=cl2uid[r_hell,false,utrain]
                 else rld:=cl2uid[r_uac ,false,utrain];
      else
         rld:=cl2uid[race,false,utrain];
      end;

      if(rld<>UID_FAPC)then
       if(u_e[false,utrain]<_ulst[rld].max)then _unit_add(x-60+random(120),y-60+random(120),rld,rld_a,true);

      if(_lcu>0)then
      begin
         {$IFDEF _FULLGAME}
         PlaySND(snd_teleport,u);
         _effect_add(_lcup^.x,_lcup^.y,_lcup^.y+map_flydpth[_lcup^.uf]+1,EID_Teleport);
         {$ENDIF}
         if(g_mode=gm_coop)and(player=0)then _lcup^.buff[ub_advanced]:=_bufinf;
      end;
   end;
   rld:=rld_r;
end;  }

procedure _cmp_initmap;
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
{
function _cmp_chucl(tr,bp,bc,i:byte;bblds:TSoB):byte;
var thc,brc,gc,twc:byte;
begin
   bc:=(5-bc)div 2;
   thc:=3-bc;
   brc:=8-bc;
   if(_players[bp].race=r_uac)
   then gc :=((6-bc) div 2)+1
   else gc :=6-bc;
   twc:=20-bc*2;
   _cmp_chucl:=255;
   with _players[bp] do
    while true do
     case tr of
    0: if(tr in bblds)and(ucl_e[true,tr]<thc)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=3;
    1: if(tr in bblds)and(ucl_e[true,tr]<brc)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=2;
    2: if(tr in bblds)and(ucl_e[true,tr]<gc)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=5;
    3: if(tr in bblds)and(ucl_e[true,tr]=0)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=1;
    5: if(tr in bblds)and(ucl_e[true,tr]=0)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=6;
    6: if(tr in bblds)and(ucl_e[true,tr]=0)then   // and(ucl_e[true,3]>0)
       begin
          _cmp_chucl:=tr;
          break;
       end
       else tr:=8;
    8: if(tr in bblds)and(ucl_e[true,tr]=0)then   // and(ucl_e[true,6]>0)and(_bc_g(c_upgr,upgr_2tier))
       begin
          _cmp_chucl:=tr;
          break;
       end
       else
         if((i mod 2)=0)                        // and(ucl_e[true,6]>0)and(_bc_g(c_upgr,upgr_2tier))
         then tr:=7
         else tr:=4;
    4: if(tr in bblds)and(ucl_e[true,tr]<twc)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else break;
    7: if(tr in bblds)and(ucl_e[true,tr]<twc)then
       begin
          _cmp_chucl:=tr;
          break;
       end
       else break;
     end;
end;

procedure _cmp_createbase(pbx,pby,bdir:integer;pbp,pbc,uidcn:byte;bblds,uulds:TSoB);
var tx,ty:integer;
    ucl,i:byte;
begin
   i   :=0;
   if(pbc>4)then pbc:=4;
   inc(pbc,pbc div 2);
   {
   0 1 2 3 4
   0 1 3 4 6
   }

   while true do
   begin
      ucl:=255;
      case i of
      0 : with _players[pbp] do
          begin
             tx:=pbx;
             ty:=pby;
             ucl:=_cmp_chucl(0,pbp,pbc,i,bblds);
          end;
      1..12 :
          if((i mod 2)=0)then
          begin
             inc(bdir,30);
             tx:=pbx+round(cos(bdir*degtorad)*165);
             ty:=pby+round(sin(bdir*degtorad)*165);
             ucl:=_cmp_chucl(3,pbp,pbc,i,bblds);
          end
          else
          begin
             inc(bdir,30);
             tx:=pbx+round(cos(bdir*degtorad)*240);
             ty:=pby+round(sin(bdir*degtorad)*240);
             ucl:=_cmp_chucl(2,pbp,pbc,i,bblds);
          end;
      13..24:
          begin
             if(i=13)
             then inc(bdir,15)
             else inc(bdir,30);
             tx:=pbx+round(cos(bdir*degtorad)*330);
             ty:=pby+round(sin(bdir*degtorad)*330);
             ucl:=_cmp_chucl(0,pbp,pbc,i,bblds);
          end;
      25..36:
          begin
             if(i=25)
             then inc(bdir,15)
             else inc(bdir,30);
             tx:=pbx+round(cos(bdir*degtorad)*405);
             ty:=pby+round(sin(bdir*degtorad)*405);
             ucl:=_cmp_chucl(0,pbp,pbc,i,bblds);
          end;
      else
        break;
      end;
      inc(i,1);

      with _players[pbp] do
       if((i mod 7)<=pbc)or(i=1)then
       begin
          if(i=1)and(uidcn>0)
          then _unit_add(tx,ty,uidcn,pbp,true)
          else
            if(ucl<255)then
            begin
               if(race=r_hell)and(ucl=1)and(9 in bblds)then ucl:=9;
               if(race=r_uac )and(ucl=0)and(9 in bblds)then ucl:=9;
               if(_unit_grbcol(tx,ty,_ulst[cl2uid[race,true,ucl]].r,255,0,true)=0)then
               begin
                  _unit_add(tx,ty,cl2uid[race,true,ucl],pbp,true);
                  if(31 in uulds)then _effect_add(tx,ty,9999,EID_Teleport);
               end;
            end;

         // if(ucl_c[false]>=ai_maxarmy)then continue;
          ucl:=i mod 12;

          if(race=r_uac)then
           case ucl of
           7 : if(ucl_e[false,ucl]>2)then continue;
           8 : if(ucl_e[false,ucl]>4)then continue;
           end;
          if(race=r_hell)then
           case ucl of
           8 : if(ucl_e[false,ucl]>9)then continue;
           end;

          if(ucl in uulds)and(ucl_e[false,ucl]<_ulst[cl2uid[race,false,ucl]].max)then
          _unit_add(tx-60,ty-60,cl2uid[race,false,ucl],pbp,true);
          if(31 in uulds)then _effect_add(tx-60,ty-60,9999,EID_Teleport);
       end;
   end;
end;

{procedure _cm_fullmapbase(pbp,pbc,uidcn:byte;bblds,uulds:TSoB);
var cnt,ix,iy,ir:integer;
    ucl,i:byte;
begin
   ix :=integer(map_seed*pbp)-integer(pbc*57);
   iy :=pbp+pbc*57;
   ir :=map_mw div 2;
   i  :=0;
   ucl:=0;
   if(pbc>4)then pbc:=4;           //0..4
   inc(pbc,pbc div 2);
   {
   0 1 2 3 4
   0 1 3 4 6
   }

   with _players[pbp] do
   repeat
   begin
      ucl:=_cmp_chucl(0,pbp,pbc,i,bblds);
      cnt:=0;
      repeat
         ix:=_genx(ix+iy,map_mw,true);
         iy:=_genx(iy+ix,map_mw,true);
         inc(cnt,1);
      until (_spch(ix,iy,0)=false)and(_unit_grbcol(ix,iy,_ulst[cl2uid[race,true,ucl]].r,255,true)=0)and(cnt<100)and(dist2(ix,iy,ir,ir)<=ir);

      inc(i,1);

      if(cnt<100)then
       if((i mod 5)<=pbc)or(i=1)then
       begin
          if(i=1)and(uidcn>0)
          then _unit_add(ix,iy,uidcn,pbp,true)
          else
            if(ucl<255)then
            begin
               if(9 in bblds)then
                case race of
                 r_hell : if(ucl=1)then ucl:=9;
                 r_uac  : if(ucl=0)then ucl:=9;
                end;
               _unit_add(ix,iy,cl2uid[race,true,ucl],pbp,true);
            end;

          if(ucl_c[false]>=ai_maxarmy)then continue;
          ucl:=i mod 12;

          if(race=r_uac)then
           case ucl of
           7 : if(ucl_e[false,ucl]>2)then continue;
           8 : if(ucl_e[false,ucl]>4)then continue;
           end;

          if(ucl in uulds)and(ucl_e[false,ucl]<_ulst[cl2uid[race,false,ucl]].max)then
           _unit_add(ix-60,iy-60,cl2uid[race,false,ucl],pbp,true);
       end;
   end;
   until (ucl_c[false]>=ai_maxarmy)or(ucl=255)or(i>=MaxPlayerUnits);
end;  }

procedure cmp_code;
var i:integer;
begin
   {case _cmp_sel of
   0 : begin
          i:=_players[1].ucl_c[false];
          if(i<8 )then i:=8;
          _units[1].rld_r:=i;

          if(g_step=300)then
          begin
             _effect_add(map_psx[0]-100,map_psx[0]-100,9999,EID_Teleport);
             _effect_add(map_psx[0]-100,map_psx[0]+100,9999,EID_Teleport);
             _effect_add(map_psx[0]+100,map_psx[0]-100,9999,EID_Teleport);
             _effect_add(map_psx[0]+100,map_psx[0]+100,9999,EID_Teleport);
             _unit_add(map_psx[0]-100,map_psx[0]-100,UID_HTower,0,true);
             _unit_add(map_psx[0]+100,map_psx[0]-100,UID_HTower,0,true);
             _unit_add(map_psx[0]-100,map_psx[0]+100,UID_HTower,0,true);
             _unit_add(map_psx[0]+100,map_psx[0]+100,UID_HTower,0,true);
             PlaySND(snd_teleport,nil);
          end;

          if((g_step mod 300)=0)then
           with _players[0] do
            if(ucl_e[false,4]<4)then
            begin
               _effect_add(map_psx[0],map_psx[0],9999,EID_Teleport);
               _unit_add(map_psx[0],map_psx[0],UID_Baron,0,true);
               PlaySND(snd_teleport,0);
            end;

          if(team_army[2]<5)then G_WTeam:=1;
          if(_players[0].ucl_e[true,15]=0)then G_WTeam:=2;
       end;
   1 : begin
          if(team_army[2]<5)then G_WTeam:=1;
          if(_players[1].army=0)then G_WTeam:=2;
       end;

   2 : begin
          i:=_players[1].ucl_c[false];
          if(i<8 )then i:=8;
          if(i>15)then dec(i,8);
          _units[1].rld_r:=i;

          if(g_step=300)then
          begin
             _effect_add(map_psx[0]-100,map_psx[0]-100,9999,EID_Teleport);
             _effect_add(map_psx[0]-100,map_psx[0]+100,9999,EID_Teleport);
             _effect_add(map_psx[0]+100,map_psx[0]-100,9999,EID_Teleport);
             _effect_add(map_psx[0]+100,map_psx[0]+100,9999,EID_Teleport);
             _unit_add(map_psx[0]-100,map_psx[0]-100,UID_HTower,0,true);
             _unit_add(map_psx[0]+100,map_psx[0]-100,UID_HTower,0,true);
             _unit_add(map_psx[0]-100,map_psx[0]+100,UID_HTower,0,true);
             _unit_add(map_psx[0]+100,map_psx[0]+100,UID_HTower,0,true);

             PlaySND(snd_teleport,nil);
          end;

          if(team_army[2]<4)then G_WTeam:=1;
          if(_players[0].ucl_e[true,15]=0)then G_WTeam:=2;
       end;
   3 : begin
          if(G_Step=67000)then
          begin
             with _players[2] do begin ai_attack:=2;                  end;
             with _players[3] do begin ai_attack:=2;upgr[29]:=1;end;
             with _players[4] do begin ai_attack:=2;upgr[29]:=1;end;
          end;

          if(G_Step=71940)then//
          begin
             _players[0].ai_pushpart:=0;
             _players[0].ai_attack:=2;
             _players[0].ai_skill:=4;

             with _players[2] do FillChar(upgr,SizeOf(upgr),0);
             with _players[3] do FillChar(upgr,SizeOf(upgr),0);
             with _players[4] do FillChar(upgr,SizeOf(upgr),0);

             ui_msks:=15;
             PlaySNDM(snd_hell);
          end;

          if(G_Step=72000)then
          begin
             theme_map_lqt:=3;
             MakeLiquid;
             for i:=1 to MaxDoodads do
              with map_dds[i] do
               if(t in [DID_liquidR1,DID_liquidR2,DID_liquidR3,DID_liquidR4])then mmc:=map_mm_liqc;
             map_bminimap;
          end;

          if(G_Step>72000)then
           if((G_Step mod 60)=0)and(_players[0].army<100)then
           begin
              for i:=1 to 100 do
               case random(4) of
               0: _unit_add(random(map_mw),0             ,UID_Cacodemon,0,true);
               1: _unit_add(random(map_mw),map_mw        ,UID_Cacodemon,0,true);
               2: _unit_add(0             ,random(map_mw),UID_Cacodemon,0,true);
               3: _unit_add(map_mw        ,random(map_mw),UID_Cacodemon,0,true);
               end;
           end;

          if(G_Step<71940)then
           if(_players[0].ucl_e[true,8]<5)then G_WTeam:=2;

          if(team_army[2]<4)then G_WTeam:=1;
       end;
   4 : begin
          if(G_Step=60)then
          begin
             _unit_add(map_psx[0]-100,map_psy[0]    ,UID_Pain,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             _unit_add(map_psx[0]    ,map_psy[0]-300,UID_Pain,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             _unit_add(map_psx[0]+100,map_psy[0]+200,UID_Pain,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             _unit_add(map_psx[0]+200,map_psy[0]-400,UID_Pain,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             _unit_add(map_psx[0]-200,map_psy[0]+400,UID_Pain,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             PlaySND(snd_teleport,nil);
          end;
          if(G_Step=180)then
          begin
             _cmp_createbase(map_psx[0]+200,map_psy[0]-200,270 ,1,4        ,UID_HMonastery,[0..7],[0..6,31]);
             _unit_add(map_psx[0]-200,map_psy[0]+200,UID_HMonastery,0,true);with _lcup^ do begin buff[ub_advanced]:=255;_effect_add(x,y,9999,EID_Teleport);end;
             PlaySND(snd_teleport,nil);
          end;
          if(G_Step=400)then
          begin
             _players[2].state:=ps_comp;
             _players[3].state:=ps_comp;
             _players[4].state:=ps_comp;
          end;
          if(G_Step>600)then
          begin
             if(team_army[2]<4)then G_WTeam:=1;
             if(_players[1].army=0)then G_WTeam:=2;
          end;
       end;
   5 : begin
          if(team_army[2]<4)then G_WTeam:=1;
          if(team_army[1]<1)then G_WTeam:=2;
       end;
   6 : begin
          if(G_Step=100)then
          begin
             _cmp_createbase(map_psx[0],map_psy[0],0  ,1,5        ,UID_HFortress           ,[0..6],[0..6,31]);
             PlaySND(snd_teleport,nil);
          end;
          if(G_Step>120)then
          begin
             if(team_army[2]<4)then G_WTeam:=1;
             if(_units[101].hits<0)then G_WTeam:=2;     //_players[1].army=0
          end;
       end;
   7 : begin
           if(team_army[2]<1)then G_WTeam:=1;
       end;
   end; }
end;



{procedure _cmp_createmap(seed:word;mw:integer;trt,lqt,liq,obs:byte);
begin
   map_seed:=seed;
   map_mw  :=mw;
   map_trt :=trt;
   map_lqt :=lqt;
   map_liq :=liq;
   map_obs :=obs;
   Map_Vars;
   MakeTerrain;
   MakeLiquid;
end;  }


procedure _CMPMap;
var i:byte;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
      with _players[i] do
       if(race=r_random)then race:=1+random(2);
   end;
   g_addon:=(_cmp_sel>3);

   {case _cmp_sel of
   0: // PHOBOS INVASION
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(19929, 4000, 3      ,           0,        0,         1);

      map_psx[0]:=map_mw div 2;
      map_psy[0]:=map_psx[0];
      map_psr[0]:=base_ir;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=0;

      with _players[0] do
      begin
         state:=ps_comp;
         race := r_hell;
         team := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_upgr ,[]);
         _bc_ss(@a_units,[]);
         _upgr_ss(@upgr ,[0..5,8],race,4);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=100;
         ai_attack  :=0;
      end;plcolor[0]:=c_orange;
      with _players[1] do
      begin
         state:=ps_play;
         race := r_hell;
         team := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_units,[1,2]);
         _bc_ss(@a_upgr ,[0,1,3,4]);
         _upgr_ss(@upgr ,[0,1,3,4],race,4-cmp_skill);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;

      with _players[2] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..3]);
         _bc_ss(@a_units,[0..1]);
         _bc_ss(@a_upgr ,[]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=3;
         ai_maxarmy :=26+cmp_skill;
         ai_pushpart:=15;
         ai_attack  :=0;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..3]);
         _bc_ss(@a_units,[0..1]);
         _bc_ss(@a_upgr ,[]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=3;
         ai_maxarmy :=21+cmp_skill;
         ai_pushpart:=15;
         ai_attack  :=0;
      end;
      with _players[4] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..3]);
         _bc_ss(@a_units,[0..2]);
         _bc_ss(@a_upgr ,[]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=3;
         ai_maxarmy :=20+cmp_skill;
         ai_pushpart:=15;
         ai_attack  :=0;
      end;

      _unit_add(map_psx[0],map_psy[0],UID_Portal,0,true);
      _units[1].buff[ub_advanced]:=255;
      _units[1].rld_a:=1;

      _cm_fullmapbase(2,cmp_skill,UID_UBaseNuc,[0..cmp_skill],[0..4]);
      _cm_fullmapbase(3,cmp_skill,UID_UBaseCom,[0..cmp_skill],[0..2]);
      _cm_fullmapbase(4,cmp_skill,UID_UBaseRef,[0,1,2,3,5],[0..cmp_skill]);
   end;

   1:  // MILITARY BASE
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(26141, 5000, 4      ,           0,        2,         0);

      map_psx[0]:=map_mw div 7;
      map_psy[0]:=map_psx[0];

      map_psx[2]:=map_mw-(map_mw div 4);
      map_psy[2]:=map_psx[2];
      map_psx[1]:=map_psx[2]-2600;
      map_psy[1]:=map_psy[2]-600;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=(vid_fps*60*2)-(cmp_skill*10);

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_upgr ,[]);
         _bc_ss(@a_units,[]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=2;
         ai_maxarmy :=45;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;plcolor[0]:=c_orange;
      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..5]);
         _bc_ss(@a_units,[1,2,4]);
         _bc_ss(@a_upgr ,[0..5,7..9]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      with _players[2] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_units,[0..2]);
         _bc_ss(@a_upgr ,[0..2]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=3;
         ai_maxarmy :=25;
         ai_pushpart:=25;
         ai_attack  :=1;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[1..4]);
         _bc_ss(@a_units,[0..3]);
         _bc_ss(@a_upgr ,[0..4,6..9]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=2;
         ai_maxarmy :=20+5*cmp_skill;
         ai_pushpart:=15-cmp_skill*2;
         ai_attack  :=0;
      end;
      with _players[4] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[1..6]);
         _bc_ss(@a_units,[0..4]);
         _bc_ss(@a_upgr ,[0..4,6..10]);
         _upgr_ss(@upgr ,[10],race,2);

         ai_skill   :=4;
         ai_maxarmy :=20+5*cmp_skill;
         ai_pushpart:=_uclord_p-cmp_skill;
         ai_attack  :=0;
      end;

      map_psr[0]:=base_rr;

      _cmp_createbase(map_psx[0],map_psy[0],0  ,1,1        ,0           ,[0,1,2,3,4  ],[1,2,4]);

      _cmp_createbase(map_psx[1],map_psy[1],0  ,3,cmp_skill,UID_UBaseLab,[1,2,3,4,5  ],[0..cmp_skill]);
      _cmp_createbase(map_psx[2],map_psy[2],0  ,4,cmp_skill,UID_UBaseMil,[0..cmp_skill,6],[0..cmp_skill]);

      _cm_fullmapbase(2,cmp_skill,0,[0..cmp_skill],[0..2]);
   end;

   2: // DEIMOS INVASION
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(26141, 5000, 2      ,           1,        3,         2);

      map_psx[0]:=map_mw div 2;
      map_psy[0]:=map_psx[0];
      map_psr[0]:=base_ir;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=0;

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_upgr ,[]);
         _bc_ss(@a_units,[0,1,2,3,4,6,7]);
         _upgr_ss(@upgr ,[0,1,2,3,4,6,7],race,2);//c_upgr:=a_upgr;

         ai_skill   :=2;
         ai_maxarmy :=45;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;plcolor[0]:=c_orange;
      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_units,[0,1,2,3,4,5]);
         _bc_ss(@a_upgr ,[0,1,4,7]);
         _upgr_ss(@upgr ,[0,1,4,7],race,2); //c_upgr:=a_upgr;

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      with _players[2] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..5]);
         _bc_ss(@a_units,[0..5,7]);
         _bc_ss(@a_upgr ,[3..9]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=4;
         ai_maxarmy :=50;
         ai_pushpart:=15;
         ai_attack  :=1;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..5]);
         _bc_ss(@a_units,[0..5,7]);
         _bc_ss(@a_upgr ,[3..9]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=4;
         ai_maxarmy :=45;
         ai_pushpart:=15;
         ai_attack  :=1;
      end;
      with _players[4] do
      begin
         state:= ps_comp;

         race := r_uac;
         team := 2;

         _bc_ss(@a_build,[1..6]);
         _bc_ss(@a_units,[0..5,7]);
         _bc_ss(@a_upgr ,[3..9]);
         _upgr_ss(@upgr ,[10],race,2);

         ai_skill   :=4;
         ai_maxarmy :=40;
         ai_pushpart:=15;
         ai_attack  :=1;
      end;

      _unit_add(map_psx[0],map_psy[0],UID_Portal,0,true);
      _units[1].buff[ub_advanced]:=255;
      _units[1].rld_a:=1;

      _cm_fullmapbase(2,cmp_skill,UID_UBaseRef,[0..5],[0..cmp_skill,6,7]);
      _cm_fullmapbase(3,cmp_skill,UID_UBaseCom,[0..5],[0..cmp_skill,6,7]);
      _cm_fullmapbase(4,cmp_skill,UID_UBaseRef,[0..5],[0..cmp_skill,6,7]);
   end;

   3: // Pentagram of Death
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(26141, 6000, 11     ,           1,        4,         4);

      map_psx[0]:=map_mw div 2;
      map_psy[0]:=map_psx[0];
      map_psr[0]:=base_rr;

      map_psx[1]:=map_mw div 8;
      map_psy[1]:=map_mw div 4;
      map_psr[1]:=base_ir;

      map_psx[2]:=map_mw-map_psx[1];
      map_psy[2]:=map_mw-map_psy[1];

      map_psx[3]:=map_psx[1];
      map_psy[3]:=map_psy[2];
      map_psr[3]:=base_ir;

      map_psx[4]:=map_psx[2]-base_r;
      map_psy[4]:=map_psy[1];
      map_psr[4]:=base_ir;

      inc(map_psx[1],base_rr);
      dec(map_psy[1],base_r);

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=(vid_fps*60*3)-(cmp_skill*15);

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_units,[]);
         _bc_ss(@a_upgr ,[0..5]);
         _upgr_ss(@upgr ,[],race,2);//c_upgr:=a_upgr;

         ai_skill   :=2;
         ai_maxarmy :=45;
         ai_pushpart:=100;
         ai_attack  :=0;

         menerg:=1;
      end;plcolor[0]:=c_orange;
      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..4,6]);
         _bc_ss(@a_units,[0..5]);
         _bc_ss(@a_upgr ,[0..5,7,10]);
         _upgr_ss(@upgr ,[cmp_skill..4,10],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=100;
         ai_attack  :=1;
      end;

      with _players[2] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..cmp_skill+1,7]);
         _bc_ss(@a_upgr ,[0..cmp_skill,10]);
         _upgr_ss(@upgr ,[29],race,2);

         ai_skill   :=3;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..3,5..7]);
         _bc_ss(@a_upgr ,[0..cmp_skill,10]);
         _upgr_ss(@upgr ,[28],race,2);

         ai_skill   :=3;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;
      with _players[4] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..3,5..7]);
         _bc_ss(@a_upgr ,[0..cmp_skill,10]);
         _upgr_ss(@upgr ,[28],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      _unit_add(map_psx[0],map_psy[0]-base_ir,UID_HAltar,0,true);
      _unit_add(map_psx[0]-100,map_psy[0]-base_ir,UID_HTower,0,true);
      _unit_add(map_psx[0]+100,map_psy[0]-base_ir,UID_HTower,0,true);
      _unit_add(map_psx[0],map_psy[0]-base_ir,UID_Cacodemon,0,true);
      _unit_add(map_psx[0],map_psy[0]-base_ir,UID_Cacodemon,0,true);
      _unit_add(map_psx[0],map_psy[0]-base_ir,UID_Cacodemon,0,true);
      _unit_add(map_psx[0],map_psy[0]-base_ir,UID_Cacodemon,0,true);

      _unit_add(map_psx[0]+base_ir,map_psy[0]-100,UID_HAltar,0,true);
      _unit_add(map_psx[0]+base_ir+100,map_psy[0]-50,UID_HTower,0,true);
      _unit_add(map_psx[0]+base_ir+100,map_psy[0]-150,UID_HTower,0,true);
      _unit_add(map_psx[0]+base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_ir,map_psy[0]-100,UID_Cacodemon,0,true);

      _unit_add(map_psx[0]-base_ir,map_psy[0]-100,UID_HAltar,0,true);
      _unit_add(map_psx[0]-base_ir-100,map_psy[0]-50 ,UID_HTower,0,true);
      _unit_add(map_psx[0]-base_ir-100,map_psy[0]-150,UID_HTower,0,true);
      _unit_add(map_psx[0]-base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_ir,map_psy[0]-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_ir,map_psy[0]-100,UID_Cacodemon,0,true);

      _unit_add(map_psx[0]+base_r,map_psy[0]+base_ir-100,UID_HAltar,0,true);
      _unit_add(map_psx[0]+base_r+50 ,map_psy[0]+base_ir-50 ,UID_HTower,0,true);
      _unit_add(map_psx[0]+base_r+100,map_psy[0]+base_ir-100,UID_HTower,0,true);
      _unit_add(map_psx[0]+base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]+base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);

      _unit_add(map_psx[0]-base_r,map_psy[0]+base_ir-100,UID_HAltar,0,true);
      _unit_add(map_psx[0]-base_r-50 ,map_psy[0]+base_ir-50 ,UID_HTower,0,true);
      _unit_add(map_psx[0]-base_r-100,map_psy[0]+base_ir-100,UID_HTower,0,true);
      _unit_add(map_psx[0]-base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);
      _unit_add(map_psx[0]-base_r,map_psy[0]+base_ir-100,UID_Cacodemon,0,true);

      _cmp_createbase(map_psx[0],map_psy[0],0  ,1,4        ,0           ,[0..4,6],[0..5]);

      _cmp_createbase(map_psx[3],map_psy[3],0  ,2,0,0,[0..cmp_skill],[0..cmp_skill,7]);
      _unit_add(map_psx[2],map_psy[2],UID_UCommandCenter,2,true);
      _unit_add(map_psx[2],map_psy[2]+150,UID_UMilitaryUnit,2,true);
      _cmp_createbase(map_psx[2],map_psy[2],0  ,2,0,0,[0..cmp_skill],[0..cmp_skill,7]);
      _cmp_createbase(map_psx[1],map_psy[1],0  ,3,0,0,[0..cmp_skill],[0..cmp_skill,7]);
      _cmp_createbase(map_psx[4],map_psy[4],0  ,4,0,0,[0..cmp_skill],[0..cmp_skill,7]);
   end;

   4: // Quarry
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(5587 , 5500, 8      ,           0,        0,         4);

      map_psx[0]:=map_mw div 8;
      map_psy[0]:=map_mw-map_psx[0];
      map_psr[0]:=base_r;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=0;

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[]);
         _bc_ss(@a_units,[0,7,12..17]);
         _bc_ss(@a_upgr ,[0..2,10,11]);
         _upgr_ss(@upgr ,[],race,2);//c_upgr:=a_upgr;

         ai_skill   :=4;
         ai_maxarmy :=100-(cmp_skill*13);
         ai_pushpart:=0;
         ai_attack  :=2;
         menerg:=10;
      end;plcolor[0]:=c_orange;
      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..7,12..17]);
         _bc_ss(@a_upgr ,[0..11]);
         _upgr_ss(@upgr ,[cmp_skill..4],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      with _players[2] do
      begin
         state := ps_play;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..7]);
         _bc_ss(@a_units,[0..cmp_skill+1,7,8]);
         _bc_ss(@a_upgr ,[0..cmp_skill+1,9,10]);
         _upgr_ss(@upgr ,[29],race,2);

         ai_skill   :=3;
         ai_maxarmy :=25+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state := ps_play;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..7]);
         _bc_ss(@a_units,[0..cmp_skill+1,7,8]);
         _bc_ss(@a_upgr ,[0..cmp_skill+1,9,10]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=2;
         ai_maxarmy :=35+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;
      with _players[4] do
      begin
         state := ps_play;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..7]);
         _bc_ss(@a_units,[0..cmp_skill+1,7,8]);
         _bc_ss(@a_upgr ,[0..cmp_skill+1,9,10]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=4;
         ai_maxarmy :=35+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      map_psr[0]:=base_rr+base_ir;

      _cmp_createbase(map_psx[0]-20,map_psy[0],0  ,3,1        ,0 ,[1],[0]);

      _cm_fullmapbase(2,cmp_skill,0,[0..5],[]);
      _cm_fullmapbase(3,cmp_skill,0,[0..5],[]);
      _cm_fullmapbase(4,cmp_skill,0,[0..5],[]);
   end;

   5: // Hell On mars
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(55870, 4500, 9      ,           0,        0,         0);

      map_psx[1]:=map_mw div 3;
      map_psy[1]:=map_mw div 6;
      map_psx[2]:=map_psx[1]+base_rr;
      map_psy[2]:=map_psy[1]+200;

      map_psx[3]:=map_mw-map_psx[1];
      map_psy[3]:=map_mw-map_psy[1];
      map_psx[4]:=map_mw-map_psx[2];
      map_psy[4]:=map_mw-map_psy[2];

      map_psx[0]:=map_psx[3];
      map_psy[0]:=map_psy[3];

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=0;

      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..8,12..17]);
         _bc_ss(@a_upgr ,[0..11,15]);
         _upgr_ss(@upgr ,[cmp_skill..11],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;
      with _players[2] do
      begin
         state := ps_comp;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..6,12..17]);
         _bc_ss(@a_upgr ,[0..11,15]);
         _upgr_ss(@upgr ,[cmp_skill..11],race,2);  //

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;plcolor[2]:=c_orange;

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..cmp_skill]);
         _bc_ss(@a_units,[0..cmp_skill]);
         _bc_ss(@a_upgr ,[]);
         _upgr_ss(@upgr ,[],race,2);

         ai_skill   :=3;
         ai_maxarmy :=20+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=0;
      end;plcolor[0]:=c_aqua;
      with _players[3] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..9]);
         _bc_ss(@a_upgr ,[0..11,14]);
         _upgr_ss(@upgr ,[0..cmp_skill+3],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;
      with _players[4] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..9]);
         _bc_ss(@a_upgr ,[0..11]);
         _upgr_ss(@upgr ,[0..cmp_skill+3],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      map_psr[3]:=base_rr+400;
      map_psr[4]:=base_rr+400;

      _cmp_createbase(map_psx[1],map_psy[1],45 ,3,cmp_skill+2,UID_UBaseMil,[0..cmp_skill,9],[0..6]);
      _cmp_createbase(map_psx[2],map_psy[2],45 ,4,cmp_skill+2,UID_UBaseMil,[0..cmp_skill,9],[0..6]);
      _cm_fullmapbase(0,cmp_skill,0,[1..cmp_skill+1],[0..cmp_skill]);

      _cmp_createbase(map_psx[3],map_psy[3],225,1,4        ,0           ,[0..6],[0..cmp_skill]);
      _cmp_createbase(map_psx[4],map_psy[4],225,2,4        ,0           ,[0..6],[0..6]);
   end;

   6: // Hell on Earth
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(6646 , 6000, 5      ,           0,        4,         1);

      map_psx[0]:=map_mw div 2;
      map_psy[0]:=map_psx[0];

      map_psx[1]:=map_mw div 8;
      map_psy[1]:=(map_mw div 4);

      map_psx[2]:=map_mw-map_psx[1];
      map_psy[2]:=map_mw-map_psy[1];

      map_psx[3]:=map_psx[1];
      map_psy[3]:=map_psy[2];

      map_psx[4]:=map_psx[2]-base_r;
      map_psy[4]:=map_psy[1];

      inc(map_psx[1],base_rr);
      dec(map_psy[1],base_r);

      dec(map_psx[2],base_rr);
      inc(map_psy[2],200);

      g_addon:=false;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=(vid_fps*60*4)-(cmp_skill*10);

      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..6,12..17]);
         _bc_ss(@a_upgr ,[0..10]);
         _upgr_ss(@upgr ,[cmp_skill..4,10],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..cmp_skill,7]);
         _bc_ss(@a_upgr ,[0..cmp_skill]);
         _upgr_ss(@upgr ,[13],race,2);

         ai_skill   :=3;
         ai_maxarmy :=20+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=0;
      end;plcolor[0]:=c_white;
      with _players[2] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..cmp_skill+1,7]);
         _bc_ss(@a_upgr ,[0..cmp_skill,10]);
         _upgr_ss(@upgr ,[13],race,2);

         ai_skill   :=3;
         ai_maxarmy :=20+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;plcolor[2]:=c_aqua;
      with _players[3] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..cmp_skill+1]);
         _bc_ss(@a_upgr ,[0..cmp_skill,10]);
         _upgr_ss(@upgr ,[13],race,2);

         ai_skill   :=2;
         ai_maxarmy :=25+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=0;
      end;
      with _players[4] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..6]);
         _bc_ss(@a_units,[0..cmp_skill+2,7]);
         _bc_ss(@a_upgr ,[0..cmp_skill+2,10]);
         _upgr_ss(@upgr ,[13],race,2);

         ai_skill   :=4;
         ai_maxarmy :=25+cmp_skill*2;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      map_psr[0]:=base_rr;

      _cmp_createbase(map_psx[1],map_psy[1],0  ,0,1        ,UID_UCBuild             ,[0..cmp_skill],[0..cmp_skill]);
      _cm_fullmapbase(0,cmp_skill,0,[0..cmp_skill],[]);

      _cmp_createbase(map_psx[2]+1,map_psy[2],0  ,2,cmp_skill,UID_UCBuild             ,[0..cmp_skill],[0..cmp_skill]);
      _cmp_createbase(map_psx[3]+2,map_psy[3],0  ,3,cmp_skill,UID_UCBuild             ,[0..cmp_skill],[0..cmp_skill]);
      _cmp_createbase(map_psx[4]+3,map_psy[4],0  ,4,cmp_skill,UID_UCBuild             ,[0..cmp_skill],[0..cmp_skill]);
   end;

   7: // Cosmodrome
   begin
      //              seed, size, terrain, liquid type, liquit r, obstacles
      _cmp_createmap(134  , 6000, 15     ,           2,        4,         4);

      map_psx[0]:=map_mw-(map_mw div 8);
      map_psy[0]:=map_mw div 7;
      map_psr[0]:=base_r;

      map_psx[1]:=map_mw div 2;
      map_psy[1]:=map_psx[1];
      map_psr[1]:=base_rr+base_r;

      map_psx[2]:=map_psx[1];
      map_psy[2]:=map_psy[1]-base_r;

      map_psx[3]:=map_psx[1]-base_r;
      map_psy[3]:=map_psy[1]+base_r;

      map_psx[4]:=map_psx[1]+base_r;
      map_psy[4]:=map_psy[1]+base_r;

      Map_Make;

      HPlayer:=1;

      cmp_ait2p:=0;

      with _players[1] do
      begin
         state := ps_play;
         race  := r_hell;
         team  := 1;

         _bc_ss(@a_build,[0..8]);
         _bc_ss(@a_units,[0..9]);
         _bc_ss(@a_upgr ,[0..15]);
         _upgr_ss(@upgr ,[cmp_skill..4,11],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=1;
      end;

      with _players[0] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[1..7]);
         _bc_ss(@a_units,[0..cmp_skill+2,7,11]);
         _bc_ss(@a_upgr ,[0..cmp_skill+6]);
         _upgr_ss(@upgr ,[0..cmp_skill+2,10,11,12],race,2);

         ai_skill   :=4;
         ai_maxarmy :=100;
         ai_pushpart:=0;
         ai_attack  :=2;
      end;plcolor[0]:=c_blue;

      with _players[2] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..9]);
         _bc_ss(@a_units,[0..cmp_skill+7,11]);
         _bc_ss(@a_upgr ,[0..cmp_skill+7]);
         _upgr_ss(@upgr ,[0..cmp_skill+2],race,2);

         ai_skill   :=4;
         ai_maxarmy :=25+cmp_skill;
         ai_pushpart:=100;
         ai_attack  :=0;
      end;plcolor[2]:=c_lime;
      with _players[3] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..9]);
         _bc_ss(@a_units,[0..cmp_skill+7]);
         _bc_ss(@a_upgr ,[0..cmp_skill+7]);
         _upgr_ss(@upgr ,[0..cmp_skill+7],race,2);

         ai_skill   :=4;
         ai_maxarmy :=25+cmp_skill;
         ai_pushpart:=100;
         ai_attack  :=0;
      end;
      with _players[4] do
      begin
         state := ps_comp;
         race  := r_uac;
         team  := 2;

         _bc_ss(@a_build,[0..9]);
         _bc_ss(@a_units,[0..cmp_skill+7,11]);
         _bc_ss(@a_upgr ,[0..cmp_skill+7]);
         _upgr_ss(@upgr ,[0..cmp_skill+7],race,2);

         ai_skill   :=4;
         ai_maxarmy :=25+cmp_skill;
         ai_pushpart:=100;
         ai_attack  :=0;
      end;plcolor[4]:=c_lime;

      map_psr[1]:=base_rr+base_rr;

      _cmp_createbase(map_psx[0],map_psy[0],90 ,1,3        ,0,[0..8],[0,3..9]);

      _unit_add(map_psx[1]-201,map_psy[1]-200,UID_USPort,0,true);with _lcup^ do rld:=vid_fps*60-(cmp_skill*10);
      _unit_add(map_psx[1]+201,map_psy[1]-200,UID_USPort,0,true);with _lcup^ do rld:=vid_fps*120-(cmp_skill*10);
      _unit_add(map_psx[1],map_psy[1]+201,UID_USPort,0,true);    with _lcup^ do rld:=vid_fps*180-(cmp_skill*10);
      _unit_add(map_psx[1],map_psy[1]-100,UID_UVehicleFactory,0,true);
      _unit_add(map_psx[1],map_psy[1]+20,UID_UMilitaryUnit,0,true);

      _cmp_createbase(map_psx[2],map_psy[2]-200,5  ,2,cmp_skill,UID_UBaseMil,[0..cmp_skill+2,9],[0..cmp_skill+4]);
      _cmp_createbase(map_psx[3],map_psy[3]    ,0  ,3,cmp_skill,UID_UBaseNuc,[0..cmp_skill+2,9],[0..cmp_skill+4]);
      _cmp_createbase(map_psx[4],map_psy[4]    ,10 ,4,cmp_skill,UID_UBaseLab,[0..cmp_skill+2,9],[0..cmp_skill+4]);
   end;



   else
     Map_randommap;
     Map_Vars;
     MakeTerrain;
     MakeLiquid;
     Map_Make;
   end; }

   _moveHumView(map_psx[0],map_psy[0]);
end;

   }
