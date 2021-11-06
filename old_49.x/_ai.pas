
type TCntr = array[0.._uts] of integer;
    PTCntr = ^TCntr;

procedure _setAI(p:byte);
begin
   with _players[p] do
   begin
      ai_pushpart := 2;
      ai_maxarmy  := 100;
      ai_attack   := 0;

    case ai_skill of
      1 : begin  //
             _bc_ss(@a_build,[0..3]);
             if(race=r_hell)
             then _bc_ss(@a_units,[0..3])
             else _bc_ss(@a_units,[0..3,7]);
             _bc_ss(@a_upgr ,[0..4,6]);

             ai_maxarmy :=25;
             ai_pushpart:=18;
          end;
      2 : begin
             _bc_ss(@a_build,[0..6]);
             if(race=r_uac)then
             begin
                _bc_ss(@a_units,[0..4,7]);
             end
             else
             begin
                _bc_ss(@a_units,[0..4]);
             end;
             _bc_ss(@a_upgr ,[0..upgr_boost-1]);

             ai_maxarmy :=45;
             ai_pushpart:=10;
          end;
      3 : begin  // HMP
             _bc_ss(@a_build,[0..7]);
             if(race=r_hell)
             then _bc_ss(@a_units,[0..5,8..10])
             else _bc_ss(@a_units,[0..9]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);
             ai_maxarmy :=100;
          end;
      4 : begin  // UV
             _bc_ss(@a_build,[0..11]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);
          end;
      5 : begin  // Nightmare
             _bc_ss(@a_build,[0..11]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             //_upgr_ss(@upgr ,[upgr_mainr],race,1);
          end;
      6 : begin  // hell masacre
             _bc_ss(@a_build,[0..11]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_attack,upgr_mainr],race,1);
          end;
      7 : begin  // Super Nightmare
             _bc_ss(@a_build,[0..11]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld],race,1);
          end;
      8 : begin  // HELL
             _bc_ss(@a_build,[0..11]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld,upgr_advbar],race,1);
          end;
    else
       a_build:=0;
       a_units:=0;
       a_upgr :=0;
    end;

    if(g_mode=gm_ct)or(ai_skill>6)then ai_attack:=1;

    case race of
    r_hell:
      case ai_skill of //
      0,1  : ;
      2    : _bc_sa(@a_units,[12..13]);
      3    : _bc_sa(@a_units,[12..16]);
      else   _bc_sa(@a_units,[12..18]);
      end;
    end;
    //if(race=r_uac)then _bc_sa(@a_units,[12..18]);
   end;
end;

procedure _unit_ai0(u:integer);
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

   with _units[u] do
    with _players[player] do
     case uid of
       UID_URocketL  : if(rld=0)then
                       begin
                          uo_x:=alrm_x;
                          uo_y:=alrm_y;
                       end;
       UID_FAPC      : begin
                          case map_aifly of
                          false : if(alrm_r<base_r)then uo_id:=ua_unload;
                          true  : if(alrm_r<180   )then uo_id:=ua_unload;
                          end;
                          if(g_mode=gm_ct)and(ai_ptd<=g_ct_pr)then uo_id:=ua_unload;
                          uo_tar:=0;
                          if(order=1)then order:=0;
                       end;
       UID_Engineer,
       UID_Medic     : if(tar1>0)and(melee)
                       then order:=1
                       else
                         if(order=1)then order:=0;
      else
         if(order=1)then order:=0;
      end;
end;

procedure _unit_aiUBC(u:integer;tu:PTUnit;ud:integer;teams:boolean);
const bweight : array[false..true] of integer = (1,5);
begin
   with _units[u] do
   with _players[player] do
   begin
      case uid of
      UID_LostSoul,
      UID_HEye: if(ud<sr)then
                 if(teams)then
                 begin
                    if(tu^.uid=UID_HEye)then ai_uc_a+=1;
                 end
                 else
                   if(tu^.uid<>UID_UCommandCenter)then ai_uc_e+=1;
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
                  then ai_uc_a+=bweight[tu^.isbuild]
                  else ai_uc_e+=bweight[tu^.isbuild];
      UID_Engineer:
                if(ud<150)then
                 if(teams)then
                 begin
                    if(tu^.uid=UID_Mine)then ai_uc_a+=1
                 end
                 else ai_uc_e+=1;
      UID_UCommandCenter:
                if(ud<sr)then
                 if(tu^.isbuild=false)
                 or((tu^.uid=uid)and(tu^.speed>0)and(upgr[upgr_ucomatt]>0))then
                  if(teams)
                  then ai_uc_a+=1
                  else ai_uc_e+=1;
      else
       if(ud<sr)then
        if(teams)
        then ai_uc_a+=1
        else ai_uc_e+=1;
      end;
   end;
end;

function _unit_aiC(u,uc,ud:integer;tu:PTUnit):boolean;
begin
   _unit_aiC:=true;
   with _units[u] do
   with _players[player] do
   begin
      if(tu^.isbuild)and(tu^.uf=uf_ground)and(tu^.speed=0)then
       if(ud<ai_bd)and(tu^.buff[ub_invis]=0)then
        if not(tu^.uid in [UID_Mine,UID_HEye])then
        begin
           ai_bd:=ud;
           ai_bx:=tu^.x;
           ai_by:=tu^.y;
           if(sel)then
           begin
              dbgai_bx:=ai_bx;
              dbgai_by:=ai_by;
           end;
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
         if(uid in [UID_APC,UID_FAPC])then
          if(_itcanapc(@_units[u],tu))and(ud<ai_apcd)and(tu^.order<>1)then
          begin
             order  :=1;
             ai_apcd:=ud;
             uo_x   :=tu^.x;
             uo_y   :=tu^.y;
             dir    :=p_dir(x,y,uo_x,uo_y);
             if(ud<melee_r)then uo_tar:=uc;
          end;

         if(isbuild=false)and(race=r_uac)and(uid<>UID_UTransport)then
          if(tu^.uid=UID_UVehicleFactory)and(buff[ub_advanced]=0)and(tu^.buff[ub_advanced]>0)and(tu^.rld=0)and(ud<base_rr)and(alrm_r>base_r)then
          begin
             order:=1;
             uo_x :=tu^.x;
             uo_y :=tu^.y;
             if(ud<melee_r)then _unit_UACUpgr(u,tu);
          end;

         if(race=r_hell)then
          case uid of
          UID_HMonastery:
            if(tu^.isbuild=false)then
            begin
               if(tu^.uid in demons)and(tu^.buff[ub_advanced]=0)and(upgr[upgr_6bld]>0)then
               begin
                  if(tu^.uid=UID_LostSoul)and(u_e[false,7]>0)then exit;
                  upgr[upgr_6bld]-=1;
                  tu^.buff[ub_advanced]:=_bufinf;
                  {$IFDEF _FULLGAME}
                  _unit_PowerUpEff(uc,snd_hupgr);
                  {$ENDIF}
               end;
            end
            else
             if(rld<=0)and(tu^.buff[ub_pboost]<=0)and(upgr[upgr_boost]>0)then
              if(tu^.ucl=1)or(tu^.ucl=3)then
               if(tu^.rld>boost_time)then
               begin
                  tu^.buff[ub_pboost]:=boost_time;
                  rld:=boost_rld;
               end;

          UID_HAltar:
            if(tu^.buff[ub_invuln]=0)and(upgr[upgr_hinvuln]>0)and(tu^.isbuild=false)then
            if(tu^.tar1>0)and(tu^.buff[ub_pain]>0)then              //(tu^.hits<tu^.mhits)
            begin
               if(u_c[false]>10)then
                if(tu^.ucl<2)or(tu^.uid in [UID_Pain,UID_ZFormer])then exit;
               upgr[upgr_hinvuln]-=1;
               tu^.buff[ub_invuln]:=hinvuln_time;
               {$IFDEF _FULLGAME}
               _unit_PowerUpEff(uc,snd_hpower);
               {$ENDIF}
            end;
          end;
         if(race=r_uac)then
          case uid of
          UID_UVehicleFactory:
             if(tu^.isbuild)and(rld<=0)and(tu^.buff[ub_pboost]<=0)and(upgr[upgr_boost]>0)then
              if(tu^.ucl=1)or(tu^.ucl=3)then
               if(tu^.rld>boost_time)then
               begin
                  tu^.buff[ub_pboost]:=boost_time;
                  rld:=boost_rld;
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

function _ai_get_max_enrg(pl:byte;rrr:boolean):byte;
begin
   with _players[pl] do
   begin
      case ai_skill of
      0  : _ai_get_max_enrg:=5;
      1  : _ai_get_max_enrg:=10;
      2  : _ai_get_max_enrg:=30;
      3  : _ai_get_max_enrg:=60;
      4  : _ai_get_max_enrg:=85;
      5  : _ai_get_max_enrg:=95;
      else _ai_get_max_enrg:=110;
      end;
      if(g_mode in [gm_3fort,gm_2fort,gm_inv])then _ai_get_max_enrg+=10;
      if(rrr)then _ai_get_max_enrg+=4;
   end;
end;

procedure ai_trybuild(x,y,r:integer;bp:byte;alrm:boolean;bnms:PTCntr;twrs:byte);
const
  Com = 0;
  Bar = 1;
  Gen = 2;
  Smt = 3;
  Tw1 = 4;
  X5  = 5;
  Adv = 6;
  Tw2 = 7;
  X8  = 8;
  Tw3 = 10;
var d:single;
    maxe,
    l:integer;
   bt:byte;
   kx,ky:integer;
procedure set_bld(ucl,cnt:byte);
begin
   with _players[bp] do
   begin
      case ucl of
   Com : if(u_e[true,ucl]>=bnms^[ucl])then exit;
   Bar : if(u_e[true,ucl]>=bnms^[ucl])then exit;
   Gen : begin
         if(menerg>=maxe)then exit;
         if(race=r_uac)then cnt:=cnt-(cnt div 2);
         end;
   Smt : if(u_e[true,ucl]>=bnms^[ucl])then exit;
   Tw1,
   Tw2,
   Tw3: begin
         case random(3) of
         0: ucl:=Tw1;
         1: ucl:=Tw2;
         2: ucl:=Tw3;
         end;
         if(twrs>1)and(u_e[true,0]<2)then exit;
         if(twrs>8)and(alrm=false)then exit;
         if(twrs>=bnms^[ucl])then exit;
         end;
      end;
      if(u_e[true,ucl]>=cnt)then exit;
   end;
   if(_bldCndt(bp,ucl))then exit;

   bt:=ucl;
end;

begin
   maxe:=_ai_get_max_enrg(bp,false);

   bt:=255;
   set_bld(random(12),100);

   with _players[bp] do
   begin
      if(ai_skill>1)then
      begin
         if(ai_skill>3)then
         begin
            if(ai_skill>4)
            then set_bld(Com,6+g_startb)
            else set_bld(Com,7);
            set_bld(Bar,8);
            if(upgr[upgr_boost]>0)then set_bld(X8,1);
            set_bld(Com,4);
            set_bld(Bar,5);
            if(u_eb[true,0]>0)then set_bld(Gen,30);
            set_bld(X5 ,1);
            set_bld(Adv,1);
            set_bld(Smt,1);
            if(u_eb[true,0]>0)then set_bld(Gen,12+upgr[upgr_mainr]+ai_skill);
            set_bld(Com,2);
         end;
         if(u_eb[true,1]>0)then set_bld(Tw1,2);
         if(ai_skill>4)then
         begin
            set_bld(Bar,1);
            set_bld(Gen,11+ai_skill);
            //if(g_mode=gm_2fort)then
            if(2<u_eb[true,0])and(u_eb[true,0]<8)then set_bld(Com,(menerg+4) shr 3);
         end
         else
         begin
            set_bld(Bar,2);
            set_bld(Gen,7+ai_skill);
            set_bld(Bar,1);
         end;
         if(alrm)then set_bld(Tw1,15);
      end;
   end;

   if(bt=255)then exit;

   d:=random(360);
   if(g_mode=gm_royl)then
   begin
      l:=dist2(x,y,map_cx,map_cx);
      if(l>(g_royal_r div 2))then
       if((l+base_ir)>g_royal_r)or(bt=0)
       then d:=p_dir(x,y,map_cx,map_cx)-_randomr(100);
   end;

   d:=d*degtorad;

   l:=random(r);
   x:=x+trunc(l*cos(d));
   y:=y-trunc(l*sin(d));

   with _players[bp] do
    if(ai_skill>2)
    then _building_newplace(x,y,cl2uid[race,true,bt],bp,@kx,@ky)
    else
    begin
       kx:=x;
       ky:=y;
    end;

   _unit_startb(kx,ky,bt,bp);
end;

procedure ai_utr(u,m:integer);
begin
   with _units[u] do
   with _players[player] do
   if(u_c[false]<ai_maxarmy)and(rld<=0)then
   begin
      case m of
0:    if(ubx[1]=u)
      then ai_utr(u,1)   // choose
      else
        if(map_aifly)and(g_mode<>gm_inv)
        then ai_utr(u,2)
        else ai_utr(u,3);
1:    if(ai_skill<2)then    // u1
      case race of
      r_hell: ai_utr(u,3);
      r_uac : begin
                 if(u_e[false,7]<1)then _unit_straining(u,7);
                 ai_utr(u,3);
              end;
      end
      else
        case race of
         r_hell :  begin
                      if(u_e[false,5]<1 )then _unit_straining(u,5); // cyb
                      if(u_e[false,6]<1 )then _unit_straining(u,6); // mind
                      if(u_e[false,0]<1 )then _unit_straining(u,0); // lost
                      if(rld=0)then
                       if(map_aifly)
                       then ai_utr(u,2)
                       else ai_utr(u,3);
                   end;

         r_uac  :  begin
                      if(u_e[false,0]<3)and(upgr[upgr_mines]>0)then _unit_straining(u,0);
                      if(u_e[false,7]<map_ffly_fapc[map_aifly])then _unit_straining(u,7);
                      if(ai_skill>2)then
                       case g_addon of
                        false: if(u_e[false,8]<8)then _unit_straining(u,8);
                        true : if(u_e[false,8]<5)then _unit_straining(u,8);
                       end;
                      if(rld=0)then
                       if(map_aifly)
                       then ai_utr(u,2)
                       else ai_utr(u,3);
                   end;
        end;
2:                                   // fly
        case race of
         r_hell : if(u_c[false]<15)
                  then ai_utr(u,3)
                  else
                    case random(3) of
                    0 : _unit_straining(u,0);
                    1 : _unit_straining(u,3);
                    2 : if(u_e[false,7]<7)
                        then _unit_straining(u,7)
                        else _unit_straining(u,0);
                    end;
         r_uac  :  ai_utr(u,3);
        end;

3:   if(u_c[false]<10)               // default
     then _unit_straining(u,random(3))
     else
       case race of
       r_hell : begin
                   m:=random(18);
                   if(alrm_r<base_r)or(u_c[false]<10)
                   then m:=random(4)
                   else
                   begin
                      if(u_e[true,1]<15)then
                       if(u_e[false,3]<10)then _unit_straining(u,3);
                      if(_uclord>15)
                      then begin if(u_e[false,8]<5 )then _unit_straining(u,8);end
                      else begin if(u_e[false,4]<8 )then _unit_straining(u,4);end;
                      if(u_e[false,10]<5 )then _unit_straining(u,10);
                   end;
                   case m of
                    1,
                    12: if(ai_skill>3)and(u_e[true,1]<10)then m:=3;
                    7 : if(u_e[false,7]<6)
                        then _unit_straining(u,7)
                        else ai_utr(u,3);
                   else
                    _unit_straining(u,m);
                   end;
                end;
       r_uac  : begin
                   if(g_addon)and(random(3)>0)
                   then _unit_straining(u,9+random(3))
                   else
                   begin
                      if(alrm_r<base_r)or(u_c[false]<10)
                      then m:=random(4)
                      else
                      begin
                         if(u_e[false,3]<8)then _unit_straining(u,3);
                         if(u_e[false,5]<8)then _unit_straining(u,5);
                         if(u_e[false,6]<5)then _unit_straining(u,6);
                         if(map_aifly)then _unit_straining(u,11);
                         m:=random(7);
                      end;

                      if(m<2)then
                       if(u_e[false,m]>=8)then m:=2+random(4);

                      _unit_straining(u,m);
                   end;
                end;
       end;

      end;
   end;
end;

procedure ai_useteleport(u:integer);
var tu:PTUnit;
    ust,
    u2t:integer;
begin
   with _units[u] do
    with _players[player] do
     if(ubx[5]>0)then
     begin
        tu:=@_units[ubx[5]];

        u2t:=dist2(x,y,tu^.x,tu^.y)+1;

        if(tu^.buff[ub_advanced]>0)and(tu^.rld=0)and(u2t>base_rr)and(alrm_r>base_r)then
         if(tu^.alrm_r<base_rr)then
         begin
            _unit_teleport(u,tu^.x,tu^.y);
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
               if(ucl>2)then
               begin
                  ust:=4+upgr[upgr_5bld]*2;
                  case uid of
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

        uo_x:=tu^.x;
        uo_y:=tu^.y;

        if(u2t<tu^.r)and(tu^.rld=0)then
        begin
           tu^.uo_x:=(alrm_x-sign(alrm_x-x)*base_r)-base_r+random(base_rr);
           tu^.uo_y:=(alrm_y-sign(alrm_y-y)*base_r)-base_r+random(base_rr);

           if(uf=uf_ground)then
            if(_unit_OnDecorCheck(tu^.uo_x,tu^.uo_y))then exit;

           _unit_teleport(u,tu^.uo_x,tu^.uo_y);
           _teleport_rld(tu,mhits);
        end;
     end;
end;

procedure ai_ups(u:integer);
var npt:byte;
begin
   with _units[u] do
   with _players[player] do
   begin
      if(ai_skill>2)then
      begin
         if(g_mode<>gm_inv     )then _unit_supgrade(u,upgr_mainm);
         if(upgr[upgr_vision]=0)then _unit_supgrade(u,upgr_vision);
         if(upgr[upgr_mainr ]=0)
         or(u_e[true,0]<3      )then _unit_supgrade(u,upgr_mainr);
         if(u=ubx[3])then
          case race of
          r_hell: begin
                     _unit_supgrade(u,upgr_boost);
                     if(u_eb[true,6]>0)then _unit_supgrade(u,upgr_6bld);
                  end;
          r_uac : if(random(2)=0)
                  then _unit_supgrade(u,upgr_boost)
                  else _unit_supgrade(u,upgr_6bld );
          end;
         if(race=r_uac)then _unit_supgrade(u,upgr_plsmt);

         if(ai_skill>4)then
          if(u_e[true,3]>3)then
          begin
             _unit_supgrade(u,upgr_attack);
             _unit_supgrade(u,upgr_armor );
             if(race=r_uac)then
             begin
                _unit_supgrade(u,upgr_mecharm );
                _unit_supgrade(u,upgr_mechspd );
             end;
             _unit_supgrade(u,upgr_melee );
             _unit_supgrade(u,upgr_mspeed);
          end;
         if(ai_skill>3)then
         begin
            if(race=r_hell)
            then _unit_supgrade(u,upgr_misfst)
            else _unit_supgrade(u,upgr_plsmt );
            if(race=r_uac)then
            begin
               _unit_supgrade(u,upgr_mines);
               _unit_supgrade(u,upgr_minesen);
               _unit_supgrade(u,upgr_ucomatt);
            end;
            if(map_aifly )then _unit_supgrade(u,upgr_mainonr);
            _unit_supgrade(u,upgr_bldenrg);
            if(race=r_hell)then
            begin
               if(map_aifly)then _unit_supgrade(u,upgr_melee);
               if(upgr[upgr_bldrep]=0)then _unit_supgrade(u,upgr_bldrep);
               _unit_supgrade(u,upgr_revmis);
            end;
         end;
      end;
      npt:=random(MaxUpgrs+1);
      if(upgr[npt]<ai_upgrlvl(player,npt))then _unit_supgrade(u,npt);
   end;
end;

function ai_outalrm(u,_r:integer;skipif:boolean):boolean;
begin
   ai_outalrm:=false;
   with _units[u] do
   begin
      if(min2(x,abs(map_mw-x))<sr)
      or(min2(y,abs(map_mw-y))<sr)then
      begin
         uo_x:=map_mw-x;
         uo_y:=map_mw-y;
      end
      else
        if(skipif)or(_r=0)or(alrm_r<_r)then
        begin
           //if(alrm_b)and(isbuild=false)then exit;
           if(x=alrm_x)and(y=alrm_y)then
           begin
              uo_x:=x-_randomr(base_r);
              uo_y:=y-_randomr(base_r);
           end
           else
           begin
              uo_x:=x-(alrm_x-x)*10;
              uo_y:=y-(alrm_y-y)*10;
           end;
        end
        else exit;
   end;
   ai_outalrm:=true;
end;

procedure ai_settar(u,tx,ty,tr:integer);
begin
   with _units[u] do
   begin
      //if(uo_x=tx)and(uo_y=ty)then
      if(x=tx)and(y=ty)then tr :=base_r;
      if(tr>0)then
      begin
         uo_x:=tx-_randomr(tr);
         uo_y:=ty-_randomr(tr);
      end
      else
      begin
         uo_x:=tx;
         uo_y:=ty;
      end;
   end;
end;

function ai_target(u:integer):boolean;
begin
   ai_target:=false;
   with _units[u] do
   begin
      if(dist2(x,y,uo_x,uo_y)<ai_d2alrm[uf>uf_ground])then
      begin
         uo_x:=_genx(uo_x+uo_y,map_mw,false);
         uo_y:=_genx(uo_y+uo_x,map_mw,false);
         alrm_x:=0;
         alrm_y:=0;
      end
      else exit;
   end;
   ai_target:=true;
end;

procedure ai_CCAttack(u:integer);
begin
   with _units[u] do
    if(ai_outalrm(u,225,(ai_uc_a=0)and(ai_uc_e>0))=false)then
     if(alrm_x>0)
     then ai_settar(u,alrm_x  ,alrm_y  ,base_r)
     else ai_target(u);
end;

procedure ai_CCOut(u:integer);
var d:integer;
begin
   with _units[u] do
    if(ai_outalrm(u,base_ir,false)=false)then
     if(ai_bx>0)then
     begin
        d:=dist2(x,y,ai_bx,ai_by);
        if(d>base_ir)
        then ai_settar(u,ai_bx,ai_by,base_r)
        else
          if(d<base_hr)
          then ai_settar(u,x-(x-ai_bx),y-(ai_by-y),base_hr)
          else
          begin
             ai_settar(u,x    ,y    ,base_r);
             _unit_action(u);
          end;
     end;
end;

function ai_CCAlarm(u:integer):boolean;
begin
   ai_CCAlarm:=true;
   with _units[u] do
   begin
      if(alrm_r<=sr)then
       if(hits<1500)or(ai_uc_e>5)or(ai_uc_a<3)then exit;
      if(g_mode=gm_royl)and(_check_royal_r(x,y,base_rr))then exit;
      with _players[player] do
       if(ai_skill>=4)and(upgr[upgr_ucomatt]>0)and(u=ubx[0])and(u_eb[true,0]>10)then exit;
   end;
   ai_CCAlarm:=false;
end;

procedure ai_buildactions(u:integer);
const maxb = 25;
      maxt = 20;
var blds: TCntr;
    twrs: integer;
begin
   FillChar(blds,SizeOf(blds),0);
   with _units[u] do
   with _players[player] do
   begin
      twrs:=u_e[true,4]+u_e[true,7]+u_e[true,10];

      case ai_skill of
      0,1 : blds[0]:=1;
      2   : blds[0]:=3;
      3   : blds[0]:=8;
      4   : blds[0]:=13;
      else  blds[0]:=17;
      end;
      blds[1 ]:=min2(max2(1,(menerg div 10)+u_e[true,0]-u_e[true,3]),maxb);

      case race of
      r_uac : blds[3 ]:=min2(ai_skill+2,menerg div 25);  //ai_CheckUpgrs(player)
      r_hell: blds[3 ]:=min2(ai_skill+2,menerg div 30);
      end;

      blds[4 ]:=min2(u_eb[true,0]*4,max2(5,maxt-u_eb[true,1]));
      blds[7 ]:=blds[4];
      blds[10]:=blds[4];

      case ucl of
      0: if(speed=0)then ai_trybuild(x,y,sr,player,(alrm_r<base_rr)and(ai_skill>2),@blds,twrs);
      1: ai_utr(u,0);
      3: ai_ups(u);
      end;

      twrs:=u_eb[true,4]+u_eb[true,7]+u_eb[true,10];

      if(ai_skill>1)then
      case uid of
       UID_URadar    : if(ai_apcd<32000)then _unit_uradar(u);
      end;

      if(ai_skill>2)then
      case uid of
       UID_HTotem    : if(upgr[upgr_b478tel]>0)then
                       begin
                          if(g_mode=gm_royl)and(_check_royal_r(x,y,base_r))then
                          begin
                             uo_x:=x+random(sr)*sign(map_cx-x);
                             uo_y:=y+random(sr)*sign(map_cx-y);
                             _unit_b247teleport(u);
                          end
                          else
                            if(alrm_x>0)and(rld<=0)then
                            begin
                               if(upgr[upgr_totminv]>0)then
                               begin
                                 if(sr<=alrm_r)and(alrm_r>=32000)then exit;
                               end
                               else
                                 if(alrm_r>=base_ir)then exit;

                               uo_x:=x+random(sr)*sign(alrm_x-x);
                               uo_y:=y+random(sr)*sign(alrm_y-y);
                               _unit_b247teleport(u);
                            end;
                       end;
       UID_HTower    : if(upgr[upgr_b478tel]>0)then
                        if(g_mode=gm_royl)and(_check_royal_r(x,y,base_r))then
                        begin
                           uo_x:=x+random(sr)*sign(map_cx-x);
                           uo_y:=y+random(sr)*sign(map_cx-y);
                           _unit_b247teleport(u);
                        end
                        else
                         if(alrm_x>0)and(alrm_r<32000)and(rld<=0)then    //and(sr<alrm_r)and
                         begin
                            if(ai_skill<5)and(alrm_r>base_rr)then exit;
                            uo_x:=x+random(sr)*sign(alrm_x-x);
                            uo_y:=y+random(sr)*sign(alrm_y-y);
                            _unit_b247teleport(u);
                         end;
       UID_HSymbol   : if(upgr[upgr_b478tel]>0)and(alrm_x>0)and(sr<alrm_r)and(alrm_r<base_rr)then
                       begin
                          uo_x:=x-random(sr)*sign(alrm_x-x);
                          uo_y:=y-random(sr)*sign(alrm_y-y);
                          _unit_b247teleport(u);
                       end;
       UID_HEye      : begin
                          if(alrm_r<base_r)then rld_a:=vid_fps;
                          if(rld_a>0)then rld_a-=1;
                          if(rld_a<=0)or(ai_uc_a>2)or(alrm_r>base_rr)then _unit_kill(u,false,false);
                       end;
       UID_Mine      : begin
                          if(alrm_r<base_r)then rld_a:=vid_fps;
                          if(rld_a>0)then rld_a-=1;
                          if(rld_a<=0)then _unit_kill(u,false,false);
                       end;
      end;

      if(ai_skill>1)then
      case uid of
      UID_HKeep : if(hits<1500)and(tar1>0)and(u_e[true,0]<3)then
                  begin
                     uo_x:=random(map_mw);
                     uo_y:=random(map_mw);
                     _unit_bteleport(u);
                  end
                  else
                    if(g_mode=gm_royl)then
                    begin
                       uo_x:=map_cx+_randomr(min2(map_cx,g_royal_r));
                       uo_y:=map_cx+_randomr(min2(map_cx,g_royal_r));
                       _unit_bteleport(u);
                    end
                    else
                      if(u_eb[true,0]>11)and(upgr[upgr_paina]>1)and(u_c[false]>40)and(ai_skill>3)then
                      begin
                         uo_x:=alrm_x-_randomr(base_r);
                         uo_y:=alrm_y-_randomr(base_r);
                         _unit_bteleport(u);
                      end;

      UID_UCommandCenter:
                  begin
                     if(speed<=0)and(ai_CCAlarm(u))then _unit_action(u) ;

                     if(speed>0)then
                      if(upgr[upgr_ucomatt]>0)and( ((u=ubx[0])and(u_eb[true,0]>10))or(alrm_r<base_rr))
                      then ai_CCAttack(u)
                      else
                        if(g_mode=gm_royl)and(_check_royal_r(x,y,base_3r))
                        then ai_settar(u,map_cx,map_cx,base_r)
                        else ai_CCOut(u);

                     if(alrm_r>base_rr)and(speed>0)then
                      if(u<>ubx[0])or(u_eb[true,0]<=10)then _unit_action(u);
                  end;
      UID_URocketL:
                  if(rld=0)and(upgr[upgr_blizz]>0)then
                   if(ai_uc_a<ai_uc_e)and(ai_uc_e>4)then _unit_URocketL(u);
      end;

      {$IFDEF _FULLGAME}
      if(menu_s2<>ms2_camp)then
      {$ENDIF}
      case uid of
      UID_HSymbol,
      UID_UGenerator    : if(bld)and(menerg>_ai_get_max_enrg(player,true))then _unit_kill(u,false,false);

      UID_HPools,
      UID_UWeaponFactory: if(ubx[3]<>u)and(rld=0)then
                           if(u_e[true,3]>blds[3])then _unit_kill(u,false,false);
      UID_UTurret,
      UID_UPTurret,
      UID_URTurret,
      UID_HTower        : if(alrm_r>base_rr)and(twrs>blds[4])then _unit_kill(u,false,false);
      UID_HTotem        : if(buff[ub_invis]=0)then
                           if(alrm_r>base_rr)and(twrs>blds[4])then _unit_kill(u,false,false);
      end;
   end;
end;


procedure ai_uorder(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin

      {$IFDEF _FULLGAME}
      if(menu_s2=ms2_camp)then
       if(g_step<cmp_ait2p)then order:=0;
      {$ENDIF}

      if(ai_pushpart<100)then
       if(army>100)or(u_c[false]>=ai_maxarmy)then
        if(_uclord>=ai_pushpart)or(apcc>0)
        then order:=2
        else
        begin
           if(ai_skill>2)then
            case race of
            r_hell : if(ucl<=2)then order:=2;
            r_uac  : if(apcm>0)then order:=2;
            end;
        end;

      case ai_attack of
      0,1 : begin
               if(ai_attack=1)then
                case race of
               r_hell : if(ucl<=3)and(u_c[false]>15)then order:=2;
               r_uac  : if(apcm>0)then order:=2;
                end;

               // harrasment
               if(ai_skill>2)then
                if(_uclord=15)and(apcc=apcm)then
                 if(map_aifly=false)or(uf>uf_ground)then order:=3;

               if(uid=UID_LostSoul)then order:=2;

               if(army<100)then
               begin
                  if(ai_skill>1)then
                   if(uid=UID_Demon)then
                    if(u_e[isbuild,ucl]<8)
                    then order:=0
                    else order:=2;

                  if(ai_skill>2)then
                  begin
                     if(uid=UID_Imp)then
                      if(u_c[false]>15)
                      then order:=2
                      else
                       if(u_e[isbuild,ucl]<8)
                       or(u_eb[true,5]=0)
                       then order:=0
                       else order:=2;
                  end;
               end;
            end;
      2   : order:=2;
      end;

      if(order<>2)and(race=r_hell)and(map_aifly)and(uf=uf_ground)then
       if(ubx[5]=0)
       then order:=0
       else
         if(ucl>2)and(max>1)then order:=0;

      if(ai_skill>3)and(army>60)then
      begin
         if(uid=UID_Demon)and(buff[ub_advanced]>0)then order:=2;
      end;

      if(u_c[true]=0)or(buff[ub_invuln]>0)then order:=2;

      case g_mode of
      gm_inv : if(player<>0)then order:=0;
      end;
   end;
end;

procedure _unit_ai1(u:integer);
var ud: integer;
begin
   with _units[u] do
   with _players[player] do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;
      uo_bx :=0;

      if(isbuild)
      then ai_buildactions(u)
      else
      begin
         if(ai_skill>3)then
          case uid of
          UID_ArchVile: if(alrm_r<base_r){and(ai_uc_a>0)and(rld<rld_a)}then uo_id :=ua_move;
          end;

         {$IFDEF _FULLGAME}
         if(menu_s2=ms2_camp)and(uid=UID_UTransport)then exit;
         {$ENDIF}

         if(order<>1)then
         begin
            if(order=0)then
            begin
               ai_uorder(u);

               case order of
               2: begin
                     ud:=0;
                     if(ubx[6]>0)then ud:=ubx[6];
                     if(ubx[2]>0)then ud:=ubx[2];
                     if(ubx[5]>0)then ud:=ubx[5];
                     if(ubx[1]>0)then ud:=ubx[1];
                     if(ubx[3]>0)then ud:=ubx[3];
                     if(ubx[0]>0)then ud:=ubx[0];

                     if(ud>0)then ai_settar(u,_genx(_units[ud].x,map_mw,false),_genx(_units[ud].y,map_mw,false),0);
                  end;
               3: if(random(2)=0)then
                  begin
                     if(random(2)=0)
                     then uo_x:=map_mw
                     else uo_x:=0;
                     uo_y:=random(map_mw);
                  end
                  else
                  begin
                     if(random(2)=0)
                     then uo_y:=map_mw
                     else uo_y:=0;
                     uo_x:=random(map_mw);
                  end;
               end;
            end;

            if(alrm_r<32000)then
            begin
               if(alrm_r<base_r)or(order=2)or(alrm_b)or((g_mode=gm_inv)and(alrm_r<base_3r))or(ai_bx=0)
               then ai_settar(u,alrm_x,alrm_y,0)
               else
                 if(g_mode=gm_ct)and(ai_pt>0)
                 then with g_cpoints[ai_pt] do ai_settar(u,px,py,base_r)
                 else
                   if(order<>3)
                   then ai_settar(u,ai_bx,ai_by,base_r)
                   else
                     if(ai_target(u))then order:=2;
            end
            else
              case order of
              2: begin
                    if(alrm_x>0)then ai_settar(u,alrm_x,alrm_y,0);
                    ai_target(u);
                 end;
              3: if(ai_target(u))then order:=2;
              else
                 if(g_mode=gm_ct)and(ai_pt>0)
                 then with g_cpoints[ai_pt] do ai_settar(u,px,py,base_r)
                 else
                   if(ai_bx>0)
                   then ai_settar(u,ai_bx,ai_by,base_r)
                   else ai_target(u);
              end;
         end;

         if(g_mode=gm_inv)and(player=0)then exit;

         case uid of
         UID_Major,
         UID_ZMajor: if(uf=uf_ground)then _unit_action(u);
         end;

         if(ai_skill>1)then
          case uid of
            UID_LostSoul:
                         if(u_e[false,0]>10)and(alrm_r=32000)and(g_mode=gm_inv)
                         then _unit_kill(u,false,false)
                         else
                           if(alrm_r<180)and(ai_uc_a<2)then _unit_action(u);
          end;

         if(ai_skill>2)then
          case uid of
            UID_FAPC: ai_outalrm(u,250,false);
            UID_APC : ai_outalrm(u,225,false);
            UID_Engineer,
            UID_Medic:if(alrm_r<=sr)then
                      begin
                         if(melee=false)and(buff[ub_advanced]=0)and(alrm_b=false)then ai_outalrm(u,0,false);
                         if(uid=UID_Engineer)and(ai_uc_a<1)then _unit_action(u);
                      end;
            UID_ArchVile:
                      if(melee=false)then ai_outalrm(u,ar,false);
            UID_Revenant: ai_outalrm(u,sr,false);

            UID_Pain :if(ai_skill>4)then
                      begin
                         if(alrm_r<32000)then _unit_action(u);
                         ai_outalrm(u,base_rr,false);
                      end;
          end;

         if(race=r_hell)and(alrm_x>0)then ai_useteleport(u);

         if(g_mode=gm_royl)then
          if(_check_royal_r(uo_x,uo_y,100))then ai_settar(u,map_cx,map_cx,g_royal_r shr 1);
      end;

      if(uo_x>map_mw)then uo_x:=map_mw;
      if(uo_y>map_mw)then uo_y:=map_mw;
      if(uo_x<0)then uo_x:=0;
      if(uo_y<0)then uo_y:=0;
   end;
end;


