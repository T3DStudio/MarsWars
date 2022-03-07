
const

aiucl_main0      : array[1..r_cnt] of byte = (UID_HKeep          ,UID_UCommandCenter);
aiucl_main1      : array[1..r_cnt] of byte = (UID_HCommandCenter ,0);
aiucl_generator  : array[1..r_cnt] of byte = (UID_HSymbol        ,UID_UGenerator    );
aiucl_barrack0   : array[1..r_cnt] of byte = (UID_HGate          ,UID_UMilitaryUnit );
aiucl_barrack1   : array[1..r_cnt] of byte = (UID_HMilitaryUnit  ,UID_UFactory      );
aiucl_smith      : array[1..r_cnt] of byte = (UID_HPools         ,UID_UWeaponFactory);
aiucl_tech0      : array[1..r_cnt] of byte = (UID_HMonastery     ,UID_UTechCenter   );
aiucl_tech1      : array[1..r_cnt] of byte = (UID_HFortress      ,UID_UNuclearPlant );
aiucl_spec0      : array[1..r_cnt] of byte = (UID_HTeleport      ,UID_URadar        );
aiucl_spec1      : array[1..r_cnt] of byte = (UID_HAltar         ,UID_URMStation    );


var

ai_grd_commander_tu,
ai_fly_commander_tu,
ai_base_tu,
ai_alarm_invis_tu,
ai_alarm_tu      : PTUnit;
ai_alarm_x,
ai_alarm_y,
ai_alarm_d,
ai_alarm_invis_x,
ai_alarm_invis_y,
ai_alarm_invis_d,
ai_base_d,

ai_enrg_cur,

ai_basep_builders,
ai_basep_need,

ai_unitp_cur,
ai_unitp_cur_na,
ai_unitp_barracks,
ai_unitp_need,
ai_upgrp_cur,
ai_upgrp_cur_na,
ai_upgrp_smiths,
ai_upgrp_need,

ai_tech0_cur,
ai_tech0_need,

ai_tech1_cur,

ai_spec0_cur,
ai_spec0_need,

ai_spec1_cur
                 : integer;


procedure PlayerSetSkirmishAIParams(p:byte);
begin
   with _players[p] do
   begin
      case ai_skill of
      0 : begin
             ai_max_energy:=600;
             ai_max_mains :=1;
             ai_max_unitps:=1;
             ai_max_upgrps:=0;
             ai_max_tech0 :=0;
             ai_max_tech1 :=0;
             ai_max_spec0 :=0;
             ai_max_spec1 :=0;
          end;
      1 : begin
             ai_max_energy:=1000;
             ai_max_mains :=3;
             ai_max_unitps:=2;
             ai_max_upgrps:=1;
             ai_max_tech0 :=0;
             ai_max_tech1 :=0;
             ai_max_spec0 :=0;
             ai_max_spec1 :=0;
          end;
      2 : begin
             ai_max_energy:=2000;
             ai_max_mains :=8;
             ai_max_unitps:=4;
             ai_max_upgrps:=1;
             ai_max_tech0 :=1;
             ai_max_tech1 :=0;
             ai_max_spec0 :=1;
             ai_max_spec1 :=0;
          end;
      3 : begin
             ai_max_energy:=32000;
             ai_max_mains :=12;
             ai_max_unitps:=8;
             ai_max_upgrps:=2;
             ai_max_tech0 :=2;
             ai_max_tech1 :=1;
             ai_max_spec0 :=2;
             ai_max_spec1 :=0;
          end;
      4 : begin
             ai_max_energy:=32000;
             ai_max_mains :=18;
             ai_max_unitps:=14;
             ai_max_upgrps:=4;
             ai_max_tech0 :=4;
             ai_max_tech1 :=1;
             ai_max_spec0 :=4;
             ai_max_spec1 :=1;
          end;
      else
             ai_max_energy:=32000;
             ai_max_mains :=25;
             ai_max_unitps:=20;
             ai_max_upgrps:=4;
             ai_max_tech0 :=4;
             ai_max_tech1 :=1;
             ai_max_spec0 :=4;
             ai_max_spec1 :=1;
      end;

      {case ai_skill of
      0,1 : ai_max_mains:=1;
      2   : ai_max_mains:=3;
      3   : ai_max_mains:=9;
      4   : ai_max_mains:=16;
      else  ai_max_mains:=25;
      end;
      {
      ai_max_ulimit,
      }

      ai_max_energy:=ai_max_mains*250+300;
      ai_max_unitps:=1;
      ai_max_upgrps:=1;
      ai_max_tech0 :=0;
      ai_max_tech1 :=0;
      ai_max_spec0 :=0;
      ai_max_spec1 :=0;

      if(ai_skill<=1)then exit;

      ai_max_unitps:=max2(3,trunc((ai_max_mains/6)*5));
      ai_max_upgrps:=max2(1,ai_max_unitps div 3);

      if(ai_skill<=2)then exit;

      ai_max_tech0 :=max2(1,ai_max_unitps div 4);
      ai_max_spec0 :=max2(1,ai_max_unitps div 4);

      if(ai_skill<=3)then exit;

      ai_max_tech1 :=1;
      ai_max_spec1 :=1; }
   end;
end;

procedure ai_clear_vars;
begin
   // nearest enemy unit or last enemy position
   ai_alarm_x       := -1;
   ai_alarm_d       := 32000;
   ai_alarm_tu      := nil;

   // nearest invisible enemy
   ai_alarm_invis_x := -1;
   ai_alarm_invis_d := 32000;
   ai_alarm_invis_tu:= nil;

   // nearest building
   ai_base_d        := 32000;
   ai_base_tu       := nil;

   // nearest commander
   ai_grd_commander_tu:= nil;
   ai_fly_commander_tu:= nil;


   ai_enrg_cur      :=0;

   ai_basep_builders:=0;
   ai_basep_need    :=0;

   ai_unitp_cur     :=0;
   ai_unitp_cur_na  :=0;
   ai_unitp_barracks:=0;
   ai_unitp_need    :=0;

   ai_upgrp_cur     :=0;
   ai_upgrp_cur_na  :=0;
   ai_upgrp_smiths  :=0;
   ai_upgrp_need    :=0;

   ai_tech0_cur     :=0;
   ai_tech0_need    :=0;

   ai_tech1_cur     :=0;

   ai_spec0_cur     :=0;
   ai_spec0_need    :=0;

   ai_spec1_cur     :=0;
end;

procedure ai_alarm_target(tu:PTUnit;x,y,ud:integer);
begin
   if(ud<ai_alarm_d)then
   begin
      if(tu<>nil)then
      begin
         ai_alarm_x :=tu^.x;
         ai_alarm_y :=tu^.y;
         ai_alarm_tu:=tu;
      end
      else
      begin
         ai_alarm_x :=x;
         ai_alarm_y :=y;
         ai_alarm_tu:=nil;
      end;
      ai_alarm_d:=ud;
   end;
end;

procedure ai_alarm_invis_target(tu:PTUnit;x,y,ud:integer);
begin
   if(ud<ai_alarm_invis_d)then
   begin
      if(tu<>nil)then
      begin
         ai_alarm_invis_x :=tu^.x;
         ai_alarm_invis_y :=tu^.y;
         ai_alarm_invis_tu:=tu;
      end
      else
      begin
         ai_alarm_invis_x :=x;
         ai_alarm_invis_y :=y;
         ai_alarm_invis_tu:=nil;
      end;
      ai_alarm_invis_d:=ud;
   end;
end;

procedure ai_collect_data(pu,tu:PTUnit;ud:integer);
procedure _setCommanderVar(pv:PPTUnit);
begin
   if(pv^=nil)
   then pv^:=tu
   else
     if(tu^.speed<pv^^.speed)
     then pv^:=tu
     else
       if (tu^.speed=pv^^.speed)
       and(tu^.unum <pv^^.unum)
       then pv^:=tu;
end;

begin
   with pu^     do
   with player^ do
   begin
      if(tu^.hits>0)then
      begin
         if(team<>tu^.player^.team)then
          if(_uvision(pu^.player^.team,tu,true))then
          begin
             ai_alarm_target(tu,0,0,ud);
             if(tu^.buff[ub_invis]>0)and(tu^.vsni[pu^.player^.team]<=0)then ai_alarm_invis_target(tu,0,0,ud);
          end;

         if(pu^.player=tu^.player)then
         begin
            if(ud<ai_base_d)and(tu^.uid^._ukbuilding)and(tu^.speed<=0)then
            begin
               ai_base_tu:=tu;
               ai_base_d :=ud;
            end;

            if(ud<base_ir)then
            begin
               if(tu^.ukfly=false)
               then _setCommanderVar(@ai_grd_commander_tu)
               else _setCommanderVar(@ai_fly_commander_tu);
            end;

            ai_enrg_cur+=tu^.uid^._generg;

            if(tu^.uid^._isbarrack)then
             if(tu^.uidi=aiucl_barrack0[race])or(tu^.uidi=aiucl_barrack1[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_unitp_cur+=MaxUnitProdsN
              else
              begin
                 ai_unitp_cur   +=1;
                 ai_unitp_cur_na+=1;
              end;

            if(tu^.uid^._issmith)then
             if(tu^.uidi=aiucl_smith[race])then
              if(tu^.buff[ub_advanced]>0)
              then ai_upgrp_cur+=MaxUnitProdsN
              else
              begin
                 ai_upgrp_cur   +=1;
                 ai_upgrp_cur_na+=1;
              end;
         end;
      end;
   end;
end;

function ai_noprod(pu:PTUnit):boolean;
var i:integer;
begin
   ai_noprod:=true;
   with pu^  do
   with uid^ do
   begin
      if(_isbarrack)then
       for i:=0 to MaxUnitProdsI do
       begin
          if(i>0)then
           if(buff[ub_advanced]<=0)then break;
          if(uprod_r[i]>0)then
          begin
             ai_noprod:=false;
             exit;
          end;
       end;
      if(_issmith)then
       for i:=0 to MaxUnitProdsI do
       begin
          if(i>0)then
           if(buff[ub_advanced]<=0)then break;
          if(pprod_r[i]>0)then
          begin
             ai_noprod:=false;
             exit;
          end;
       end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure ai_buildings(pu:PTUnit);
var  bt:byte;
      d:single;
bx,by,l:integer;
procedure SetBT(buid:byte);
var _c:cardinal;
begin
  if(bt=0)then
  begin
     _c:=_uid_conditionals(pu^.player,buid);
     if(_c=0)or(_c=ureq_energy)then bt:=buid;
  end;
end;

procedure SetBTX(buid1,buid2:byte;x:integer);
begin
   if(bt=0)then
     with pu^.player^ do
     begin
        if(uid_e[buid1]>=x)then exit;
        if(buid2>0)then
        if(uid_e[buid2]>=x)then exit;

        bt:=buid1;
     end;
end;

procedure SetBT2(b0,b1:byte);
begin
   if(bt=0)then
    if(b0=b1)or(b1=0)
    then SetBT(b0)
    else
    begin
       with pu^.player^ do
        if(uid_e[b1]<(uid_e[b0] div 2))then SetBT(b1);
       SetBT(b0);
       if(bt=0)then SetBT(b1);
    end;
end;

procedure BuildMain(x:integer);   // Builders
begin
   with pu^.player^ do
    if(ai_basep_builders<x)and(ai_basep_builders<ai_max_mains)
    then SetBT2(aiucl_main0[race],aiucl_main1[race]);
end;
procedure BuildEnergy(x:integer); // Energy
begin
   with pu^.player^ do
    if(ai_enrg_cur<x)and(ai_enrg_cur<ai_max_energy)
    then SetBT2(aiucl_generator[race],0);
end;
procedure BuildUProd(x:integer);  // Barracks
begin
    with pu^.player^ do
     if(ai_unitp_cur<x)and(ai_unitp_cur<ai_max_unitps)then
      if(ai_tech1_cur<=0)or(ai_unitp_cur_na=0)or(ai_unitp_cur<2)then
       SetBT2(aiucl_barrack0[race],aiucl_barrack1[race]);
end;
procedure BuildSmith(x:integer);  // Smiths
begin
    with pu^.player^ do
     if(ai_upgrp_cur<x)and(ai_upgrp_cur<ai_max_upgrps)then
      if(ai_tech1_cur<=0)or(ai_upgrp_cur_na=0)or(ai_upgrp_cur<2)then
       SetBT2(aiucl_smith[race],0);
end;
procedure BuildTech0(x:integer);  // Tech0  TechCenter, HellMonastery
begin
    with pu^.player^ do
     if(ai_tech0_cur<x)and(ai_tech0_cur<ai_max_tech0)
     then SetBT2(aiucl_tech0[race],0);
end;
procedure BuildTech1(x:integer);  // Tech1
begin
    with pu^.player^ do
     if(ai_tech1_cur<x)and(ai_tech1_cur<ai_max_tech1)
     then SetBT2(aiucl_tech1[race],0);
end;
procedure BuildSpec0(x:integer);  // Radar, Teleport
begin
    with pu^.player^ do
     if(ai_spec0_cur<x)and(ai_spec0_cur<ai_max_spec0)
     then SetBT2(aiucl_spec0[race],0);
end;
procedure BuildSpec1(x:integer);  // RStation, Altar
begin
    with pu^.player^ do
     if(ai_spec1_cur<x)and(ai_spec1_cur<ai_max_spec1)
     then SetBT2(aiucl_spec1[race],0);
end;

begin
   bt:=0;

   with pu^     do
   with uid^    do
   with player^ do
   if(build_cd<=0)then
   begin
      // fixed opening
      if(race=r_hell)
      then SetBTX(UID_HSymbol,UID_HASymbol,1);
      BuildEnergy(300 );
      BuildUProd (1   );
      BuildEnergy(600 );
      BuildUProd (2   );
      BuildMain  (2   );
      BuildEnergy(900 );
      BuildSmith (1   );
      BuildSpec0 (1   );
      BuildEnergy(1200);
      BuildUProd (3   );
      BuildMain  (4   );
      BuildTech0 (1   );
      BuildTech1 (1   );
      BuildSpec1 (1   );

     { // common
      BuildSmith(ai_upgrp_need);
      BuildTech0(ai_tech0_need);
      BuildSpec0(ai_spec0_need);
      BuildUProd(ai_unitp_need);
      BuildMain (ai_basep_need);   }

      if(bt=0)then exit;

      d:=random(360)*degtorad;
      l:=random(srange-_r)+_r;
      bx:=x+trunc(l*cos(d));
      by:=y-trunc(l*sin(d));

      _building_newplace(bx,by,bt,playeri,@bx,@by);

      _unit_start_build(bx,by,bt,playeri);
   end;
end;


procedure ai_UnitProduction(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   begin

   end;
end;

procedure ai_code(pu:PTUnit);
var i:integer;

function _N(pn:pinteger;mx:integer):boolean;
begin
   _N:=false;
   if(mx<1)
   then pn^:=0
   else if(mx=1)
        then pn^:=1
        else _N:=true;
end;

begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(playeri=HPlayer)and(sel)then
      begin
         if(ai_alarm_x      >-1)then UnitsInfoAddLine(x,y,ai_alarm_x,ai_alarm_y,c_red);
         if(ai_alarm_invis_x>-1)then UnitsInfoAddLine(x,y,ai_alarm_invis_x+1,ai_alarm_invis_y+1,c_aqua);
      end;

      ai_basep_builders:=uid_e[aiucl_main0   [race]]
                        +uid_e[aiucl_main1   [race]];
      ai_unitp_barracks:=uid_e[aiucl_barrack0[race]]
                        +uid_e[aiucl_barrack1[race]];
      ai_upgrp_smiths  :=uid_e[aiucl_smith   [race]];
      ai_tech0_cur     :=uid_e[aiucl_tech0   [race]];
      ai_tech1_cur     :=uid_e[aiucl_tech1   [race]];
      ai_spec0_cur     :=uid_e[aiucl_spec0   [race]];
      ai_spec1_cur     :=uid_e[aiucl_spec1   [race]];


      if(_N(@ai_basep_need,ai_max_mains ))then ai_basep_need:=mm3(1,ai_basep_builders+1           ,ai_max_mains );
      if(_N(@ai_unitp_need,ai_max_unitps))then ai_unitp_need:=mm3(1,trunc((ai_basep_builders/6)*5),ai_max_unitps);
      if(_N(@ai_upgrp_need,ai_max_upgrps))then ai_upgrp_need:=mm3(1,ai_unitp_cur div 3            ,ai_max_upgrps);
      if(_N(@ai_tech0_need,ai_max_tech0 ))then ai_tech0_need:=mm3(0,ai_unitp_cur div 4            ,ai_max_tech0 );
      if(_N(@ai_spec0_need,ai_max_spec0 ))then ai_spec0_need:=mm3(0,ai_unitp_cur div 4            ,ai_max_spec0 );

      if(sel)then
      if(k_ctrl>1)and(k_ctrl<fr_2hfps)then writeln('ai_unitp_need=',ai_unitp_need,' ai_max_unitps=',ai_max_unitps);



      case uidi of
UID_HSymbol,
UID_HASymbol   : if(cenerg>_generg)and(menerg>2200)and(uid_eb[uidi]>1)then begin _unit_kill(pu,false,true,true);exit;end;
UID_UGenerator,
UID_UAGenerator: if(cenerg>_generg)and(menerg>2200)then begin _unit_kill(pu,false,true,true);exit;end;
      else
         if(_isbarrack)or(_issmith)then
         if(ai_noprod(pu))then
         begin
            if(buff[ub_advanced]>0)
            then i:=MaxUnitProdsN
            else i:=1;

            if(_isbarrack)and(ai_unitp_cur>6)then
             if(ai_unitp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_unitp_cur_na>0))then
              if((ai_unitp_cur-i)>=ai_unitp_need)then begin _unit_kill(pu,false,true,true);exit;end;
            if(_issmith  )and(ai_upgrp_cur>3)then
             if(ai_upgrp_cur_na<=0)or((buff[ub_advanced]<=0)and(ai_upgrp_cur_na>0))then
              if((ai_upgrp_cur-i)>=ai_upgrp_need)then begin _unit_kill(pu,false,true,true);exit;end;
         end;
      end;

      if(ai_unitp_cur>=1)then
      case uidi of
UID_HSymbol    : if(ai_enrg_cur<ai_max_energy)or(uid_e[UID_HASymbol]<=0)then begin _unit_action(pu);exit;end;
UID_UGenerator : if(ai_enrg_cur<ai_max_energy)then begin _unit_action(pu);exit;end;
      else
         if(_isbarrack)or(_issmith)then begin _unit_action(pu);exit;end;
      end;

      if(n_builders>0)and(isbuildarea)then ai_buildings(pu);

      if(_isbarrack)then ai_UnitProduction(pu);
   end;
end;

{
const ucl_com = 0;
      ucl_gen = 1;
      ucl_bar = 2;
      ucl_smt = 3;
      ucl_twr = 4;
      ucl_bx5 = 5;
      ucl_bx6 = 6;
      ucl_bx8 = 8;
      ucl_bx9 = 9;


procedure _setAI(p:byte);
begin
   with _players[p] do
   begin
      ai_pushtime := vid_fps*2;    // 6+ skill
      ai_pushmin  := 55;
      ai_pushuids := [];
      ai_towngrd  := 3;
      ai_maxunits := MaxPlayerUnits;

                          ai_flags :=            aif_dattack    + aif_help     + aif_pushair;
      if(ai_skill>=2)then ai_flags := ai_flags + aif_buildseq1;
      if(ai_skill>=3)then ai_flags := ai_flags + aif_alrmtwrs   + aif_upgrseq1 + aif_usex5    + aif_useapcs   + aif_usex6     + aif_detecatcs;
      if(ai_skill>=4)then ai_flags := ai_flags + aif_hrrsmnt    + aif_CCescape + aif_specblds + aif_buildseq2 + aif_unitaacts + aif_smarttpri + aif_upgrseq2 + aif_smartbar;
      if(ai_skill>=5)then ai_flags := ai_flags + aif_CCattack   + aif_usex8    + aif_twrtlprt + aif_usex9     + aif_destrblds;
      if(ai_skill>=6)then ai_flags := ai_flags + aif_nofogblds;
      if(ai_skill>=7)then ai_flags := ai_flags + aif_hrsmntapcs;
      if(ai_skill>=8)then ai_flags := ai_flags + aif_nofogunts;

      case ai_skill of
      0 : begin
             a_build := [];
             a_units := [];
             a_upgr  := [];

             ai_pushtime := vid_fps;
             ai_towngrd  := 100;
             ai_maxunits := 0;
             ai_pushmin  := 0;
          end;
      1 : begin
             a_build := [0..2];
             a_units := [0..2];
             a_upgr  := [    ];

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 9;
             ai_maxunits := 10;
             ai_pushmin  := ai_maxunits-5;
          end;
      2 : begin  // ITYTD
             a_build := [0..3];
             case race of
             r_hell: a_units := [0..3  ];
             r_uac : a_units := [0..3,7];
             end;
             a_upgr := [0..5,6];

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 17;
             ai_maxunits := 25;
             ai_pushmin  := ai_maxunits-5;
          end;
      3 : begin  // HNTR
             a_build := [0..6];
             case race of
             r_hell: a_units := [0..4  ];
             r_uac : a_units := [0..4,7];
             end;
             a_upgr := [0..upgr_2tier-1];

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 20;
             ai_maxunits := 35;
             ai_pushmin  := ai_maxunits-5;
          end;
      4 : begin  // HMP
             a_build := [0..7,9];
             case race of
             r_hell: a_units := [0..5,8..10];
             r_uac : a_units := [0..9      ];
             end;
             a_upgr := [0..MaxUpgrs];

             ai_pushtime := vid_fps*180;
             ai_towngrd  := 10;
             ai_maxunits := 45;
             ai_pushmin  := ai_maxunits-5;
          end;
      5 : begin  // UV
             a_build := [0..14];
             a_units := [0..11];
             a_upgr  := [0..MaxUpgrs];
             ai_pushtime := vid_fps*60;
          end;
      6 : begin  // Nightmare
             a_build := [0..14];
             a_units := [0..11];
             a_upgr  := [0..MaxUpgrs];

             _upgr_ss(@upgr ,[upgr_mainr],race,1);
          end;
      7 : begin  // Super Nightmare
             a_build := [0..14];
             a_units := [0..11];
             a_upgr  := [0..MaxUpgrs];

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld],race,1);
          end;
      8 : begin  // HELL
             a_build := [0..14];
             a_units := [0..11];
             a_upgr  := [0..MaxUpgrs];

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld,upgr_advbar],race,1);
          end;
      250:begin // assault AI
            a_build := [];
            a_units := [];
            a_upgr  := [];

            ai_pushtime := vid_fps;
            ai_towngrd  := 100;
            ai_maxunits := 0;
            ai_pushmin  := 0;

            ai_flags:=aif_unitaacts+aif_detecatcs+aif_smarttpri+aif_stayathome;

            _upgr_ss(@upgr ,[0..MaxUpgrs],race,10);
            exit;
          end;
      else
         a_build:=[];
         a_units:=[];
         a_upgr :=[];
      end;

      case race of
      r_hell:
         begin
            if(map_aifly)then
            begin
               ai_flags   :=ai_flags+aif_pushuids;
               ai_pushuids:=[UID_Imp,UID_Cacodemon,UID_LostSoul,UID_Pain,UID_Cyberdemon,UID_Mastermind];
            end
            else ai_flags   :=ai_flags+aif_pushgrnd;
            case ai_skill of //
          0,1  : a_units := [12    ];
          2    : a_units := [12..13];
          3    : a_units := [12..15];
            else a_units := [12..18];
            end;
         end;
      r_uac :
         begin
            ai_flags   :=ai_flags+aif_pushgrnd;
         end;
      end;

      if(g_mode=gm_inv)then
      begin
         if(cf(@ai_flags,@aif_dattack   ))then ai_flags:=ai_flags xor aif_dattack;
         if(cf(@ai_flags,@aif_hrsmntapcs))then ai_flags:=ai_flags xor aif_hrsmntapcs;
         if(cf(@ai_flags,@aif_hrrsmnt   ))then ai_flags:=ai_flags xor aif_hrrsmnt;
      end;
   end;
end;

procedure ai_cnt_blds(pu,tu:PTUnit);
begin
   with pu^ do
   with player^ do
   if(tu^.isbuild)then
   begin
      if(tu^.isbuilder)then inc(ai_builders,1);
      if(tu^.isbarrack)then
       if(tu^.buff[ub_advanced]>0)
       then inc(ai_uprods,2)
       else inc(ai_uprods,1);
      if(tu^.issmith)then
       if(tu^.buff[ub_advanced]>0)
       then inc(ai_pprods,2)
       else inc(ai_pprods,1);
   end;
end;

procedure ai_code1(pu:PTUnit);
begin
   ai_uc_e := 0;
   ai_uc_a := 0;
   ai_apcd := 32000;
   ai_ux   := 0;
   ai_uy   := 0;
   ai_ud   := 32000;
   ai_bx   := 0;
   ai_by   := 0;
   ai_bd   := 32000;
   ai_builders:=0;
   ai_uprods  :=0;
   ai_pprods  :=0;
   ai_cnt_blds(pu,pu);

   with pu^ do
    with player^ do
     case uidi of
       UID_URocketL  : if(rld_t=0)then
                       begin
                          uo_x:=alrm_x;
                          uo_y:=alrm_y;
                       end;
       UID_Engineer,
       UID_Medic     : if(tar1>0)and(melee)
                       then order:=1
                       else
                         if(order=1)then order:=0;
      else
         if(apcc>0)and(uf>uf_ground)then
          if(cf(@ai_flags,@aif_useapcs))then
          begin
             case map_aifly of
             false : if(alrm_r<base_r)then uo_id:=ua_unload;
             true  : if(alrm_r<180   )then uo_id:=ua_unload;
             end;
             if(g_mode=gm_ct)and(ai_ptd<=g_ct_pr)then uo_id:=ua_unload;
             uo_tar:=0;
          end;
         if(order=1)then order:=0;
      end;
end;

procedure _unit_aiUBC(pu,tu:PTUnit;ud:integer;teams:boolean);
const bweight : array[false..true] of integer = (1,5);
begin
   with pu^ do
   with player^ do
   begin
      case uidi of
      UID_LostSoul,
      UID_HEye: if(ud<sr)then
                 if(teams)then
                 begin
                    if(tu^.uidi=UID_HEye)then inc(ai_uc_a,1);
                 end
                 else
                   if not(tu^.uidi in [UID_UCommandCenter,UID_HCommandCenter])then inc(ai_uc_e,1);
      UID_URadar:
                if(teams)and(ud<ai_apcd)and(tu^.alrm_r<=0)then
                begin
                   ai_apcd:=ud;
                   uo_x   :=tu^.x;
                   uo_y   :=tu^.y;
                end;
      UID_URocketL:
                if(tu^.buff[ub_invuln]=0)then
                 if(dist2(uo_x,uo_y,tu^.x,tu^.y)<=blizz_r)and(tu^.speed<13)then
                  if(teams)
                  then inc(ai_uc_a,bweight[tu^.isbuild])
                  else inc(ai_uc_e,bweight[tu^.isbuild]);
      UID_Engineer:
                if(ud<150)then
                 if(teams=false)
                 then inc(ai_uc_e,1)
                 else
                   if(tu^.uidi=UID_UMine)then inc(ai_uc_a,1);
      UID_HCommandCenter,
      UID_UCommandCenter:
                begin
                   if(uid_x[uidi]=unum)and(tu^.uidi=uidi)then
                   begin
                      if(ai_apcd=32000)then
                      begin
                         ai_apcd:=10;
                         order:=4;
                      end;
                      dec(ai_apcd,1);
                      if(ai_apcd<=0)
                      then tu^.order:=4
                      else tu^.order:=5;
                   end;

                   if(ud<sr)then
                    if(tu^.isbuild=false)
                    or((tu^.uidi=uidi)and(tu^.speed>0)and(upgr[upgr_ucomatt]>0))then
                     if(teams)
                     then inc(ai_uc_a,tu^.ucl)
                     else inc(ai_uc_e,tu^.ucl);
                end;
      else
       if(ud<sr)then
        if(teams)
        then inc(ai_uc_a,1)
        else inc(ai_uc_e,1);
      end;
   end;
end;

function _unit_aiC(pu,tu:PTUnit;ud:integer):boolean;
begin
   _unit_aiC:=true;
   with pu^ do
   with player^ do
   begin
      ai_cnt_blds(pu,tu);

      if(tu^.isbuild)and(tu^.uf=uf_ground)and(tu^.speed=0)then
       if(ud<ai_bd)and(tu^.buff[ub_invis]=0)then
        if not(tu^.uidi in [UID_UMine,UID_HEye])then
        begin
           ai_bd:=ud;
           ai_bx:=tu^.x;
           ai_by:=tu^.y;
        end;

      if(tu^.isbuild=false)then
       if(ud<ai_ud)then
       begin
          ai_ud:=ud;
          ai_ux:=tu^.x;
          ai_uy:=tu^.y;
       end;

      if(bld)and(tu^.bld)then
      begin
         if(apcm>0)then
          if(cf(@ai_flags,@aif_useapcs))then
           if(_itcanapc(pu,tu))and(ud<ai_apcd)and(tu^.order<>1)and(speed>=tu^.speed)and(tu^.alrm_r>base_ir)then
           begin
              order  :=1;
              ai_apcd:=ud;
              uo_x   :=tu^.x;
              uo_y   :=tu^.y;
              dir    :=p_dir(x,y,uo_x,uo_y);
              if(ud<melee_r)then uo_tar:=tu^.unum;
           end;

         if(isbuild=false)and(race=r_uac)and(cf(@ai_flags,@aif_usex6))then
          if(tu^.uidi=UID_UVehicleFactory)and(buff[ub_advanced]=0)and(tu^.buff[ub_advanced]>0)and(tu^.rld_t=0)and(ud<base_rr)and(alrm_r>base_r)then
          begin
             order:=1;
             uo_x :=tu^.x;
             uo_y :=tu^.y;
             if(ud<melee_r)then _unit_UACUpgr(pu,tu);
          end;

         if(race=r_hell)then
          case uidi of
          UID_HMonastery:
            if(cf(@ai_flags,@aif_usex6))then
            if(tu^.uidi in demons)and(tu^.buff[ub_advanced]=0)and(upgr[upgr_6bld]>0)and(tu^.isbuild=false)then
            begin
               if(tu^.uidi=UID_LostSoul)and(ucl_e[false,7]>0)then exit;
               dec(upgr[upgr_6bld],1);
               tu^.buff[ub_advanced]:=_bufinf;
               {$IFDEF _FULLGAME}
               _unit_PowerUpEff(tu,snd_hupgr);
               {$ENDIF}
            end;

          UID_HAltar:
            if(cf(@ai_flags,@aif_usex8))then
            if(tu^.buff[ub_invuln]=0)and(upgr[upgr_hinvuln]>0)and(tu^.isbuild=false)then
            if(tu^.tar1>0)and(tu^.hits<tu^.mhits)then
            begin
               if(ucl_c[false]>10)then
                if(tu^.ucl<2)or(tu^.uidi in [UID_Pain,UID_ZFormer])then exit;
               dec(upgr[upgr_hinvuln],1);
               tu^.buff[ub_invuln]:=hinvuln_time;
               {$IFDEF _FULLGAME}
               _unit_PowerUpEff(tu,snd_hpower);
               {$ENDIF}
            end;
          end;
      end;
   end;
   _unit_aiC:=false;
end;

function ai_upgrlvl(pl,up:byte):byte;
begin
   with _players[pl] do
   begin
      ai_upgrlvl:=upgrade_cnt[race,up];
      if(upgrade_mfrg[race,up]=false)then
       if(ai_upgrlvl>ai_skill)then ai_upgrlvl:=ai_skill;
   end;
end;

function ai_CheckUpgrs(pl:byte):byte;
var i:byte;
begin
   ai_CheckUpgrs:=0;

   with _players[pl] do
    for i:=0 to MaxUpgrs do
     if(g_addon=false)and(i>=upgr_2tier)
     then break
     else
       if(upgrade_mfrg[race,i])
       then inc(ai_CheckUpgrs,upgrade_cnt[race,i])
       else
        if(upgr[i]<ai_upgrlvl(pl,i))then inc(ai_CheckUpgrs,1);
end;

function _ai_get_max_enrg(pl:byte;rrr:boolean):byte;
begin
   with _players[pl] do
   begin
      case ai_skill of
      0  : _ai_get_max_enrg:=8;
      1  : _ai_get_max_enrg:=10;
      2  : _ai_get_max_enrg:=15;
      3  : _ai_get_max_enrg:=25;
      4  : _ai_get_max_enrg:=45;
      else _ai_get_max_enrg:=61;
      end;
      if(rrr)then inc(_ai_get_max_enrg,5);
   end;
end;

procedure ai_trybuild(x,y,r:integer;bp,builderuid:byte;alrm:boolean;alloweducl:PTSoB);
var d:single;
 maxe,
    l:integer;
   bt:byte;

procedure set_bld(aiucl,cnt:byte);
var ucl:byte;
begin
   if not(aiucl in alloweducl^)then exit;
   ucl:=255;
   with _players[bp] do
   begin
      case aiucl of
ucl_com: begin
            ucl:=0;
            if(builderuid=UID_HCommandCenter)
            then ucl:=12;
         end;
ucl_bar: begin
            ucl:=1;
            if(builderuid=UID_HCommandCenter)
            then ucl:=13;
         end;
ucl_gen: begin
            if(maxe<=menerg)then exit;
            inc(cnt,upgr[upgr_mainr]-upgr[upgr_bldenrg]);
            ucl:=2;
            case race of
            r_uac: cnt:=cnt div 2;
            end;
         end;
ucl_smt: ucl:=3;
ucl_twr: case race of
         r_hell: case random(2) of
                 0: ucl:=4;
                 1: ucl:=7;
                 end;
         r_uac : case random(3) of
                 0: ucl:=4;
                 1: ucl:=7;
                 2: ucl:=10;
                 end;
         end;
ucl_bx5: ucl:=5;
ucl_bx6: ucl:=6;
ucl_bx8: ucl:=8;
ucl_bx9: ucl:=9;
      else exit;
      end;
      if(ucl>_uts)then exit;
      if not(cl2uid[race,true,ucl] in _uids[builderuid].ups_builder)then exit;
      if(ucl_e[true,ucl]>=cnt)then exit;
   end;
   if(_bldCndt(@_players[bp],ucl))then exit;
   bt:=ucl;
end;

begin
   maxe:=_ai_get_max_enrg(bp,false);

   bt:=255;
   set_bld(random(15),100);

   with _players[bp] do
   begin
      if(cf(@ai_flags,@aif_buildseq1))then
      begin
         if(cf(@ai_flags,@aif_buildseq2))then
         begin
            set_bld(ucl_bx9,1 );
            set_bld(ucl_com,6 );
            set_bld(ucl_bar,8 );
            set_bld(ucl_com,5 );
            set_bld(ucl_gen,20);
            set_bld(ucl_bar,6 );
            set_bld(ucl_gen,18);
            set_bld(ucl_bx8,1 );
            set_bld(ucl_com,4 );
            set_bld(ucl_bar,5 );
            set_bld(ucl_gen,16);
            set_bld(ucl_bx5,1 );
            set_bld(ucl_bx6,1 );
            set_bld(ucl_smt,1 );
            set_bld(ucl_com,3 );
            set_bld(ucl_gen,10);
            set_bld(ucl_com,2 );
         end
         else set_bld(ucl_smt,1 );
         set_bld(ucl_gen,8);
         if(upgr[upgr_bldenrg]>2)then
         begin
         set_bld(ucl_bar,3);
         set_bld(ucl_com,2);
         end;
         set_bld(ucl_gen,4);
         set_bld(ucl_twr,2);
         set_bld(ucl_bar,2);
         set_bld(ucl_twr,1);
         set_bld(ucl_gen,2);
         set_bld(ucl_bar,1);
         if(alrm)then set_bld(ucl_twr,12);
      end;
   end;

   if(bt=255)then exit;

   d:=random(360)*degtorad;
   l:=random(r);
   x:=x+trunc(l*cos(d));
   y:=y-trunc(l*sin(d));

   _unit_startb(x,y,bt,bp);
end;

function ai_uprod_status(pu:PTUnit):boolean;
var i:byte;
begin
   ai_uprod_status:=false;
   with pu^ do
    if(bld)and(isbuild)then
    begin
       if(isbarrack)then
        for i:=0 to MaxUnitProds do
         if(uprod_r[i]>0)then
         begin
            ai_uprod_status:=true;
            break;
         end;
       if(issmith)then
        for i:=0 to MaxUnitProds do
         if(pprod_r[i]>0)then
         begin
            ai_uprod_status:=true;
            break;
         end;
    end;
end;


procedure ai_bar_st(pu:PTUnit;_ucl:byte;cnt:integer);
begin
   with pu^ do
    with player^ do
     if((ucl_e[false,_ucl]+uprodc[_ucl])<cnt)then _unit_straining(pu,_ucl);
end;

procedure ai_utr(pu:PTUnit;m:integer);
begin
   with pu^ do
   with player^ do
   if(ucl_c[false]<ai_maxunits)then
   begin
      if(uidi=UID_HMilitaryUnit)then
      begin
         _unit_straining(pu,12+random(7));
         exit;
      end;

      if(cf(@ai_flags,@aif_smartbar)=false)then
      begin
         m:=random(12);
         case race of
         r_uac: case m of
                7: if(ucl_e[false,7]>=min2(map_ffly_fapc[map_aifly],ai_skill))then exit;
                8: if(ucl_e[false,8]>=min2(map_gapc[g_addon]       ,ai_skill))then exit;
                end;
         r_hell:if(map_aifly)then
                begin
                   ai_bar_st(pu,3 ,10);
                   ai_bar_st(pu,0 ,10);
                end;
         end;
         _unit_straining(pu,m);
         exit;
      end;

      case race of  // default
r_hell : begin
            ai_bar_st(pu,5 ,1);
            ai_bar_st(pu,6 ,1);
            ai_bar_st(pu,0 ,2);

            if(map_aifly)then
            begin
               ai_bar_st(pu,10,5);
               if(ucl_c[false]<15)
               then _unit_straining(pu,random(3))
               else
                 case random(3) of
               0 : _unit_straining(pu,0);
               1 : _unit_straining(pu,3);
               2 : if(ucl_e[false,7]<7)
                   then _unit_straining(pu,7)
                   else _unit_straining(pu,0);
                 end;
            end
            else
            begin
               ai_bar_st(pu,8 ,10);
               ai_bar_st(pu,10,5 );
               m:=random(12);
               if(alrm_r<base_r)or(ucl_c[false]<10)
               then m:=random(4)
               else
               begin
                  if(uprodm<15)then
                   ai_bar_st(pu,3,10);
                  ai_bar_st(pu,4,8);
               end;

               _unit_straining(pu,m);
            end;
         end;

r_uac  : begin
            if(upgr[upgr_mines]>0)then
            ai_bar_st(pu,0,5);
            ai_bar_st(pu,7,map_ffly_fapc[map_aifly]);
            ai_bar_st(pu,8,map_gapc[g_addon]       );

            if(g_addon)and(random(2)=0)
            then m:=9+random(3)
            else
            begin
               if(alrm_r<base_r)or(ucl_c[false]<10)
               then m:=random(4)
               else
               begin
                  ai_bar_st(pu,3, 10);
                  ai_bar_st(pu,5 ,10);
                  ai_bar_st(pu,6 ,5 );
                  if(map_aifly)then
                  ai_bar_st(pu,11,10);
                  m:=random(7);
               end;

               if(m<2)then
                if(ucl_e[false,m]>=8)then m:=2+random(4);
            end;

            _unit_straining(pu,m);
         end;
      end;
   end;
end;

procedure ai_useteleport(pu:PTUnit);
var tu:PTUnit;
   ax,ay,
    ust,
    u2t:integer;
    pi:pinteger;
begin
   with pu^ do
    with player^ do
    begin
       pi:=@uid_x[UID_HTeleport];
       if(0<pi^)and(pi^<=MaxUnits)then
       begin
          tu:=@_units[pi^];

          u2t:=dist2(x,y,tu^.x,tu^.y)+1;

          if(tu^.alrm_r<base_rr)then
           if(tu^.buff[ub_advanced]>0)and(tu^.rld_t=0)and(u2t>base_rr)and(alrm_r>base_r)then
           begin
              _unit_teleport(pu,tu^.x,tu^.y);
              _teleport_rld(tu,mhits);
              exit;
           end;

          if(u2t>base_ir)then exit;

          case order of
          0,
          2 : begin
                 if(alrm_r<base_rr)then exit;
                 if not((order=2)or(alrm_b))then exit;

                 //ust
                 if(mhits>110)then
                 begin
                    ust:=4+upgr[upgr_5bld]*2;
                    case uidi of
                   UID_Baron:     if(ust<=_uclord)then exit;
                   UID_Cacodemon: if(ust< _uclord)then exit;
                   UID_Mastermind,
                   UID_Cyberdemon:if(map_aifly=false)
                                  then exit;
                    else exit;
                    end;
                 end;
              end;
          //3 :;
          else exit;
          end;

          ax:=uo_x;
          ay:=uo_y;
          uo_x:=tu^.x;
          uo_y:=tu^.y;

          if(u2t<tu^.r)and(tu^.rld_t=0)then
          begin
             tu^.uo_x:=(ax-sign(ax-x)*base_r)-randomr(base_r);
             tu^.uo_y:=(ay-sign(ay-y)*base_r)-randomr(base_r);

             if(uf=uf_ground)then
              if(_unit_OnDecorCheck(tu^.uo_x,tu^.uo_y))then exit;

             _unit_teleport(pu,tu^.uo_x,tu^.uo_y);
             _teleport_rld(tu,mhits);
          end;
       end;
    end;
end;

procedure ai_upgrs(pu:PTUnit);
var npt:byte;
begin
   with pu^ do
   with player^ do
   begin
      if(cf(@ai_flags,@aif_upgrseq1))then
      begin
         if(g_mode<>gm_inv)then _unit_supgrade(pu,upgr_mainm);
         if(upgr[upgr_vision]=0)then _unit_supgrade(pu,upgr_vision);
         if(upgr[upgr_mainr ]=0)or(n_builders<0)then _unit_supgrade(pu,upgr_mainr);
         if(unum=uid_x[3])then
          case race of
          r_hell: if(g_addon)then _unit_supgrade(pu,upgr_2tier);
          r_uac : if(g_addon)and(random(2)=0)
                  then _unit_supgrade(pu,upgr_2tier)
                  else _unit_supgrade(pu,upgr_6bld );
          end;
         if(race=r_uac)then _unit_supgrade(pu,upgr_plsmt);
         if(cf(@ai_flags,@aif_upgrseq2))then
         begin
            case race of
            r_hell: _unit_supgrade(pu,upgr_misfst);
            r_uac:  _unit_supgrade(pu,upgr_plsmt );
            end;
            if(race=r_uac)then
            begin
               _unit_supgrade(pu,upgr_mines);
               _unit_supgrade(pu,upgr_minesen);
               _unit_supgrade(pu,upgr_ucomatt);
            end;
            if(map_aifly )then _unit_supgrade(pu,upgr_mainonr);
            if(menerg<100)then _unit_supgrade(pu,upgr_bldenrg);
            if(race=r_hell)then
            begin
               if(map_aifly)then _unit_supgrade(pu,upgr_melee);
               if(upgr[upgr_bldrep]=0)then _unit_supgrade(pu,upgr_bldrep);
               _unit_supgrade(pu,upgr_revmis);
            end;
         end;
      end;
      npt:=random(MaxUpgrs+1);
      if(upgr[npt]<ai_upgrlvl(playeri,npt))then _unit_supgrade(pu,npt);
   end;
end;

function ai_outalrm(pu:PTUnit;_r:integer;skipif,skipab:boolean):boolean;
begin
   ai_outalrm:=false;
   with pu^ do
   begin
      if(skipab=false)then
       if(alrm_b)then exit;

      if(min2(x,abs(map_mw-x))<sr)
      or(min2(y,abs(map_mw-y))<sr)then
      begin
         uo_x:=map_mw-x;
         uo_y:=map_mw-y;
      end
      else
        if(skipif)or(_r=0)or(alrm_r<_r)then
        begin
           if(x=alrm_x)and(y=alrm_y)then
           begin
              uo_x:=x-randomr(base_r);
              uo_y:=y-randomr(base_r);
           end
           else
           begin
              uo_x:=x-(alrm_x-x);
              uo_y:=y-(alrm_y-y);
           end;
        end
        else exit;
   end;
   ai_outalrm:=true;
end;

procedure ai_settar(pu:PTUnit;tx,ty,tr:integer);
begin
   with pu^ do
   begin
      if(x=tx)and(y=ty)then tr :=base_r;
      if(tr>0)then
      begin
         uo_x:=tx-randomr(tr);
         uo_y:=ty-randomr(tr);
      end
      else
      begin
         uo_x:=tx;
         uo_y:=ty;
      end;
   end;
end;

function ai_target(pu:PTUnit):boolean;
begin
   ai_target:=false;
   with pu^ do
   if(dist2(x,y,uo_x,uo_y)<ai_d2alrm[uf>uf_ground])then
   begin
      uo_x:=_genx(uo_x+uo_y,map_mw,false);
      uo_y:=_genx(uo_y+uo_x,map_mw,false);
      alrm_x:=0;
      alrm_y:=0;
   end
   else exit;
   ai_target:=true;
end;

procedure ai_CCAttack(pu:PTUnit);
begin
   with pu^ do
    if(ai_outalrm(pu,225,(ai_uc_a=0)and(ai_uc_e>0),true)=false)then
     if(alrm_x>0)
     then ai_settar(pu,alrm_x,alrm_y,base_r)
     else ai_target(pu);
end;

procedure ai_CCOut(pu:PTUnit);
begin
   with pu^ do
    if(ai_outalrm(pu,base_ir,false,true)=false)then
     if(base_ir<ai_bd)and(ai_bd<32000)
     then ai_settar(pu,ai_bx,ai_by,base_r)
     else
     begin
        ai_settar(pu,random(map_mw),random(map_mw),0);
        _unit_action(pu);
     end;
end;

procedure ai_buildingAI(pu:PTUnit);
const maxb : array[false..true] of integer = (18, 22);
      maxt = 18;
var bucls: TSoB;
    t,
    c_twr,
    n_com,
    n_bar,
    n_smt,
    n_twr:integer;
begin
   with pu^ do
   with player^ do
   begin
      bucls:=[ucl_gen,ucl_bx5,ucl_bx6,ucl_bx8,ucl_bx9];

      // CCs
      case ai_skill of
      0,1 : n_com:=1;
      2   : n_com:=2;
      3   : n_com:=4;
      4   : n_com:=9;
      5   : n_com:=12;
      else  if(menerg>100)and(race=r_hell)
            then n_com:=12
            else n_com:=16;
      end;
      if(ai_builders<n_com)then bucls:=bucls+[ucl_com];

      // Smiths
      n_smt:=max2(1,min3(ai_CheckUpgrs(playeri),ai_skill,menerg div 11));
      if(ai_pprods<n_smt)then bucls:=bucls+[ucl_smt];

      // Bars
      n_bar:=min2(max2(2,(menerg div 6)+n_com-n_smt),maxb[ucl_eb[true,9]>0]);
      if(ai_uprods<n_bar)then bucls:=bucls+[ucl_bar];

      // Towers
      c_twr:=ucl_e[true,4 ]
            +ucl_e[true,7 ]
            +ucl_e[true,10];
      n_twr:=min2(n_builders*4,max2(5,maxt-n_bar));
      if(c_twr<n_twr)then bucls:=bucls+[ucl_twr];

      if(isbuilder)and
        (speed  =0)then ai_trybuild(x,y,sr,playeri,uidi,(alrm_r<base_rr)and(cf(@ai_flags,@aif_alrmtwrs)),@bucls);
      if(isbarrack)then ai_utr(pu,0);
      if(issmith  )then ai_upgrs(pu);

      case uidi of
UID_HKeep :
         if(hits<1500)and(tar1>0)and(uid_e[uidi]<3)then
         begin
            if(cf(@ai_flags,@aif_CCescape))then
            begin
               uo_x:=random(map_mw);
               uo_y:=random(map_mw);
               _unit_bteleport(pu);
            end;
         end
         else
           if(cf(@ai_flags,@aif_CCattack))then
            if(uid_eb[uidi]>11)and(upgr[upgr_paina]>1)and(ucl_c[false]>40)then
            begin
               uo_x:=alrm_x-randomr(base_r);
               uo_y:=alrm_y-randomr(base_r);
               _unit_bteleport(pu);
            end;

UID_HCommandCenter,
UID_UCommandCenter:
         begin
            case order of
          6,
          4 : begin
                 if(hits<2000)or(ai_uc_e>2)or(ai_uc_a<3)then
                  if(alrm_r<=sr)and(speed=0)then _unit_action(pu);

                 if(speed>0)then
                  if(ucl_e[isbuild,ucl]>8)and(alrm_r<base_rr)and(upgr[upgr_ucomatt]>0)
                  then ai_CCAttack(pu)
                  else ai_CCOut(pu);
              end;
          5 : if(speed>0)
              then ai_CCAttack(pu)
              else
                if(upgr[upgr_ucomatt]>0)then _unit_action(pu);
            end;
         end;
UID_URocketL:
         if(rld_t=0)and(upgr[upgr_blizz]>0)then
          if(ai_uc_a<ai_uc_e)and(ai_uc_e>4)then
           if(cf(@ai_flags,@aif_usex8))then _unit_URocketL(pu);

UID_URadar:
         if(ai_apcd<32000)then
          if(cf(@ai_flags,@aif_usex5))then _unit_uradar(pu);
      end;

      if(cf(@ai_flags,@aif_twrtlprt))then
      case uidi of
UID_HTotem:
         if(upgr[upgr_b478tel]>0)and(alrm_x>0)then
         begin
            if(upgr[upgr_totminv]>0)then
            begin
               if(sr<=alrm_r)and(alrm_r>=32000)then exit;
            end
            else
              if(alrm_r>=base_ir)then exit;

            uo_x:=x+random(sr)*sign(alrm_x-x);
            uo_y:=y+random(sr)*sign(alrm_y-y);
            _unit_b247teleport(pu);
         end;
UID_HTower:
         if(upgr[upgr_b478tel]>0)and(alrm_x>0)and(sr<alrm_r)and(alrm_r<base_rr)then
         begin
            uo_x:=x+random(sr)*sign(alrm_x-x);
            uo_y:=y+random(sr)*sign(alrm_y-y);
            _unit_b247teleport(pu);
         end;
UID_HSymbol:
         if(upgr[upgr_b478tel]>0)and(alrm_x>0)and(sr<alrm_r)and(alrm_r<base_rr)then
         begin
            uo_x:=x-random(sr)*sign(alrm_x-x);
            uo_y:=y-random(sr)*sign(alrm_y-y);
            _unit_b247teleport(pu);
         end;
      end;

      if(cf(@ai_flags,@aif_specblds))then
      case uidi of
UID_HEye:
         begin
            if(alrm_r<base_r)then rld_a:=vid_fps;
            if(rld_a>0)then dec(rld_a,1);
            if(rld_a<=0)or(ai_uc_a>2)or(alrm_r>base_rr)then _unit_kill(pu,false,false);
         end;
UID_UMine:
         begin
            t:=buff[ub_advanced];
            if(g_addon=false)or(upgr[upgr_minesen]>0)then
             if(alrm_r<100)
             then buff[ub_advanced]:=0
             else buff[ub_advanced]:=_bufinf;
            if(alrm_r<base_r)or(t<>buff[ub_advanced])then rld_a:=vid_fps;
            if(rld_a>0)then dec(rld_a,1);
            if(rld_a<=0)then _unit_kill(pu,false,false);
         end;
      end;

      if(cf(@ai_flags,@aif_usex9))then
      case uidi of
UID_UWeaponFactory,
UID_HPools,
UID_UMilitaryUnit,
UID_HMilitaryUnit,
UID_HGate:
         _unit_action(pu);
      end;

      inc(n_bar,2);
      inc(n_smt,2);

      if(cf(@ai_flags,@aif_destrblds))then
      case uidi of
UID_HSymbol,
UID_UGenerator:
         if(bld)and(menerg>_ai_get_max_enrg(playeri,true))then _unit_kill(pu,false,false);
UID_UMilitaryUnit,
UID_HMilitaryUnit,
UID_HGate:
         if(uid_x[uidi]<>unum)and(bld)and(ai_uprod_status(pu)=false)then
          if(ai_uprods>n_bar)then _unit_kill(pu,false,false);
UID_HPools,
UID_UWeaponFactory:
         if(uid_x[uidi]<>unum)and(ai_uprod_status(pu)=false)then
          if(ai_pprods>n_smt)then _unit_kill(pu,false,false);
UID_UTurret,
UID_UPTurret,
UID_URTurret,
UID_HTower,
UID_HTotem:
         if(buff[ub_invis]=0)then
          if(alrm_r>base_rr)and(c_twr>n_twr)then _unit_kill(pu,false,false);
      end;
   end;
end;

procedure ai_deforder(pu:PTUnit);
begin
   with pu^ do
   with player^ do
   begin
      if(inapc>0)then
      begin
         ai_deforder(@_units[inapc]);
         order:=2;
         exit;
      end;

      if(cf(@ai_flags,@aif_pushuids))then
       if not(uidi in ai_pushuids)then exit;

      if(uf=uf_ground)then
       if(cf(@ai_flags,@aif_pushgrnd)=false)then exit;

      if(uf>uf_ground)then
       if(cf(@ai_flags,@aif_pushair )=false)then exit;

      ai_pushfrmi:=max2(0,ai_pushfrmi-apcc-1);
      order:=2;
   end;
end;

procedure ai_uorder(pu:PTUnit);
begin
   with pu^ do
   with player^ do
   begin
      if(ai_pushfrmi>0)then
       if(cf(@ai_flags,@aif_dattack))then ai_deforder(pu);

      if(cf(@ai_flags,@aif_hrrsmnt))then
      begin
         case uidi of
UID_LostSoul : order:=2;
UID_Imp,
UID_Demon    : if(uid_eb[uidi]>5)then order:=3;
         end;
      end;

      if(apcm>0)then
       if(apcc=apcm)and(army>105)then
        if(cf(@ai_flags,@aif_hrsmntapcs))then order:=3;

      if(ucl_c[true]=0)or(buff[ub_invuln]>0)then order:=2;

      if(base_r<ai_bd)and(ai_bd<32000)then
      if(cf(@ai_flags,@aif_stayathome))then
      begin
         order:=0;
         if(tar1=0)then
         begin
             uo_id :=ua_move;
             tar1  :=0;
             tar1d :=32000;
             alrm_r:=32000;
         end;
      end;
   end;
end;


procedure ai_unitAI(pu:PTUnit);
const nra : array[false..true] of integer = (base_r,base_3r);
var ud: integer;
begin
   with pu^ do
   with player^ do
   begin
      if(order<>1)then
      begin
         case order of
       0:begin
            ai_uorder(pu);

            case order of
            2: begin
                  ud:=0;

                  for ud:=0 to _uts do
                   if(ucl_x[ud]>0)then break;

                  if(ud=_uts)
                  then ud:=0
                  else ud:=ucl_x[ud];

                  if(0<ud)and(ud<=MaxUnits)then ai_settar(pu,_genx(_units[ud].x,map_mw,false),
                                                             _genx(_units[ud].y,map_mw,false),0);
               end;
            3: case random(2) of
               0: begin
                     if(random(2)=0)
                     then uo_x:=map_mw
                     else uo_x:=0;
                     uo_y:=random(map_mw);
                  end;
               1: begin
                     if(random(2)=0)
                     then uo_y:=map_mw
                     else uo_y:=0;
                     uo_x:=random(map_mw);
                  end;
               end;
            end;
         end;
         end;


         if(alrm_r<32000)then  // active alarm
         begin
            if(alrm_r<nra[g_mode=gm_inv])         // alarm near
            or(order=2)                           // attack group
            or(alrm_b )                           // building alarm
            or(ai_bd=32000)                       // no buldings
            then ai_settar(pu,alrm_x,alrm_y,0)
            else
              if(g_mode=gm_ct)and(ai_pt>0)
              then with g_ct_pl[ai_pt] do ai_settar(pu,px,py,base_r)
              else
                if(order<>3)
                then ai_settar(pu,ai_bx,ai_by,base_r)
                else
                  if(ai_target(pu))then order:=2;
         end
         else
           case order of
           2: begin
                 if(alrm_x>0)then ai_settar(pu,alrm_x,alrm_y,0);
                 ai_target(pu);
              end;
           3: if(ai_target(pu))then order:=2;
           else
              if(g_mode=gm_ct)and(ai_pt>0)
              then with g_ct_pl[ai_pt] do ai_settar(pu,px,py,base_r)
              else
                if(ai_bd<32000)
                then ai_settar(pu,ai_bx,ai_by,base_r)
                else ai_target(pu);
           end;
      end;

      //if(g_mode=gm_inv)and(playern=0)then exit;

      case uidi of
      UID_Major,
      UID_ZMajor: if(uf=uf_ground)then _unit_action(pu);
      end;

      case uidi of
UID_Engineer:if(alrm_r<=sr)then
             begin
                if(cf(@ai_flags,@aif_unitaacts))then
                 if(melee=false)and(buff[ub_advanced]=0)and(alrm_b=false)then ai_outalrm(pu,0,false,false);
                if(cf(@ai_flags,@aif_detecatcs))then
                 if(uidi=UID_Engineer)and(ai_uc_a<1)then _unit_action(pu);
             end;
UID_LostSoul:if(ucl_e[false,0]>10)and(alrm_r=32000)and(g_mode=gm_inv)then
             begin
                if(cf(@ai_flags,@aif_unitaacts))then
                 _unit_kill(pu,false,false)
             end
             else
               if(alrm_r<180)and(ai_uc_a<2)then
                if(cf(@ai_flags,@aif_detecatcs))then _unit_action(pu);
      end;


      if(cf(@ai_flags,@aif_unitaacts))then
      case uidi of
UID_FAPC:    ai_outalrm(pu,250,false,true);
UID_APC :    ai_outalrm(pu,225,false,true);
UID_Medic:   if(alrm_r<=sr)then
              if(melee=false)and(buff[ub_advanced]=0)and(alrm_b=false)then ai_outalrm(pu,0,false,false);
UID_ArchVile:
             if(melee=false)and(alrm_b=false)then ai_outalrm(pu,ar,false,false);
UID_Pain :
             begin
                if(alrm_r<base_ir)then _unit_action(pu);
                ai_outalrm(pu,base_r,false,true);
             end;
UID_Flyer:   if(buff[ub_advanced]>0)then
              if(ai_uc_a<1)then
               if(ai_ux>0)
               then ai_settar(pu,ai_ux,ai_uy,base_r)
               else
                 if(ai_bd<32000)
                 then ai_settar(pu,ai_bx,ai_by,base_r)
                 else ai_outalrm(pu,base_rr,false,false)
               else
                 if(tar1d<230)then ai_outalrm(pu,0,false,false);
      end;

      if(cf(@ai_flags,@aif_usex5))then ai_useteleport(pu);
   end;
end;

procedure _unit_ai1(pu:PTUnit);
begin
   with pu^ do
   with player^ do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;
      uo_bx :=-1;

      {if(isbuild)
      then ai_buildingAI(pu)
      else ai_unitAI(pu);  }

      if(uo_x>map_mw)then uo_x:=map_mw;
      if(uo_y>map_mw)then uo_y:=map_mw;
      if(uo_x<0)then uo_x:=0;
      if(uo_y<0)then uo_y:=0;
   end;
end;
}

