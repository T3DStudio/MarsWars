
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
             _bc_ss(@a_upgr ,[0..upgr_2tier-1]);

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
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);
          end;
      5 : begin  // Nightmare
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr],race,1);
          end;
      6 : begin  // Super Nightmare
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld],race,1);
          end;
      7 : begin  // HELL
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld,upgr_advbar],race,1);
          end;
      else
         a_build:=0;
         a_units:=0;
         a_upgr :=0;
      end;

      if(g_mode=gm_ct)or(ai_skill>5)then ai_attack:=1;

      case race of
      r_hell:
        case ai_skill of //
      0,1  : ;
      2    : _bc_sa(@a_units,[12..13]);
      3    : _bc_sa(@a_units,[12..16]);
        else _bc_sa(@a_units,[12..18]);
        end;
      end;
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
       UID_URocketL  : if(rld_t=0)then
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
                    if(tu^.uid=UID_HEye)then inc(ai_uc_a,1);
                 end
                 else
                   if not(tu^.uid in [UID_UCommandCenter,UID_HCommandCenter])then inc(ai_uc_e,1);
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
                 if(teams)then
                 begin
                    if(tu^.uid=UID_Mine)then inc(ai_uc_a,1)
                 end
                 else inc(ai_uc_e,1);
      UID_HCommandCenter,
      UID_UCommandCenter:
                if(ud<sr)then
                 if(tu^.isbuild=false)
                 or((tu^.uid=uid)and(tu^.speed>0)and(upgr[upgr_ucomatt]>0))then
                  if(teams)
                  then inc(ai_uc_a,1)
                  else inc(ai_uc_e,1);
      else
       if(ud<sr)then
        if(teams)
        then inc(ai_uc_a,1)
        else inc(ai_uc_e,1);
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
          if(tu^.uid=UID_UVehicleFactory)and(buff[ub_advanced]=0)and(tu^.buff[ub_advanced]>0)and(tu^.rld_t=0)and(ud<base_rr)and(alrm_r>base_r)then
          begin
             order:=1;
             uo_x :=tu^.x;
             uo_y :=tu^.y;
             if(ud<melee_r)then _unit_UACUpgr(u,tu);
          end;

         if(race=r_hell)then
          case uid of
          UID_HMonastery:
            if(tu^.uid in demons)and(tu^.buff[ub_advanced]=0)and(upgr[upgr_6bld]>0)and(tu^.isbuild=false)then
            begin
               if(tu^.uid=UID_LostSoul)and(ucl_e[false,7]>0)then exit;
               dec(upgr[upgr_6bld],1);
               tu^.buff[ub_advanced]:=_bufinf;
               {$IFDEF _FULLGAME}
               _unit_PowerUpEff(uc,snd_hupgr);
               {$ENDIF}
            end;

          UID_HAltar:
            if(tu^.buff[ub_invuln]=0)and(upgr[upgr_hinvuln]>0)and(tu^.isbuild=false)then
            if(tu^.tar1>0)and(tu^.hits<tu^.mhits)then
            begin
               if(ucl_c[false]>10)then
                if(tu^.ucl<2)or(tu^.uid in [UID_Pain,UID_ZFormer])then exit;
               dec(upgr[upgr_hinvuln],1);
               tu^.buff[ub_invuln]:=hinvuln_time;
               {$IFDEF _FULLGAME}
               _unit_PowerUpEff(uc,snd_hpower);
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
      0  : _ai_get_max_enrg:=5;
      1  : _ai_get_max_enrg:=10;
      2  : _ai_get_max_enrg:=25;
      3  : _ai_get_max_enrg:=45;
      else _ai_get_max_enrg:=60;
      end;
      if(rrr)then inc(_ai_get_max_enrg,4);
   end;
end;

procedure ai_trybuild(x,y,r:integer;bp,builderuid:byte;alrm:boolean;alloweducl:TSoB);
var d:single;
 maxe,
    l:integer;
   bt:byte;

procedure set_bld(aiucl,cnt:byte);
var ucl:byte;
begin
   if not(aiucl in alloweducl)then exit;
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
            ucl:=0;
            if(builderuid=UID_HCommandCenter)
            then ucl:=13;
         end;
ucl_gen: ucl:=2;
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
      if not(cl2uid[race,true,ucl] in uids_builder[builderuid])then exit;
      if(ucl_e[true,ucl]>=cnt)then exit;
   end;
   if(_bldCndt(bp,ucl))then exit;

   bt:=ucl;
end;
procedure set_enrg(lvl:integer);
var ucl:byte;
begin
   ucl:=255;

   with _players[bp] do
   begin
      if(menerg>=min2(maxe,lvl))
      then exit
      else ucl:=2;
   end;

   if(_bldCndt(bp,ucl))then exit;

   bt:=ucl;
end;

begin
   maxe:=_ai_get_max_enrg(bp,false);

   bt:=255;
   set_bld(random(15),100);

   if(g_mode<>gm_coop)or(bp<>0)then
   with _players[bp] do
   begin
      if(ai_skill>1)then
      begin
         if(ai_skill>3)then
         begin
            set_bld (ucl_bx9,1);
            set_bld (ucl_com,6);
            set_bld (ucl_bar,8);
            if(upgr[upgr_2tier]>0)then
            set_bld (ucl_bx8,1);
            set_bld (ucl_com,4);
            set_bld (ucl_bar,5);
            set_enrg(50);
            set_bld (ucl_bx5,1);
            set_bld (ucl_bx6,1);
            set_bld (ucl_smt,1);
            set_bld (ucl_com,3);
            set_enrg(36+upgr[upgr_mainr]);
            set_bld (ucl_com,2);
         end;
         set_enrg(20);
         set_bld (ucl_twr,2);
         set_bld (ucl_bar,2);
         set_bld (ucl_twr,1);
         set_enrg(8);
         set_bld (ucl_bar,1);
         if(alrm)then set_bld(ucl_twr,15);
      end;
   end;

   if(bt=255)then exit;

   d:=random(360)*degtorad;
   l:=random(r);
   x:=x+trunc(l*cos(d));
   y:=y-trunc(l*sin(d));

   _unit_startb(x,y,bt,bp);
end;

function ai_uprod_status(u:integer):boolean;
var i:byte;
begin
   ai_uprod_status:=false;
   with _units[u] do
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

procedure ai_utr(u,m:integer);
begin
   with _units[u] do
   with _players[player] do
   if(ucl_c[false]<ai_maxarmy)then
   begin
      case m of
0:    if(ucl_x[1]=u)
      then ai_utr(u,1)   // choose
      else
        if(map_aifly)and(g_mode<>gm_inv)
        then ai_utr(u,2)
        else ai_utr(u,3);
1:    if(ai_skill<2)then    // u1
      case race of
      r_hell: ai_utr(u,3);
      r_uac : begin
                 if(ucl_e[false,7]<1)then _unit_straining(u,7);
                 ai_utr(u,3);
              end;
      end
      else
        case race of
         r_hell :  begin
                      if(ucl_e[false,5]<1 )then _unit_straining(u,5); // cyb
                      if(ucl_e[false,6]<1 )then _unit_straining(u,6); // mind
                      if(ucl_e[false,0]<1 )then _unit_straining(u,0); // lost
                      if(ai_uprod_status(u)=false)then
                       if(map_aifly)
                       then ai_utr(u,2)
                       else ai_utr(u,3);
                   end;

         r_uac  :  begin
                      if(ucl_e[false,0]<3)and(upgr[upgr_mines]>0)then _unit_straining(u,0);
                      if(ucl_e[false,7]<map_ffly_fapc[map_aifly])then _unit_straining(u,7);
                      if(ai_skill>2)then
                       case g_addon of
                        false: if(ucl_e[false,8]<8)then _unit_straining(u,8);
                        true : if(ucl_e[false,8]<5)then _unit_straining(u,8);
                       end;
                      if(ai_uprod_status(u)=false)then
                       if(map_aifly)
                       then ai_utr(u,2)
                       else ai_utr(u,3);
                   end;
        end;
2:                                   // fly
        case race of
         r_hell : if(ucl_c[false]<15)
                  then ai_utr(u,3)
                  else
                    case random(3) of
                    0 : _unit_straining(u,0);
                    1 : _unit_straining(u,3);
                    2 : if(ucl_e[false,7]<7)
                        then _unit_straining(u,7)
                        else _unit_straining(u,0);
                    end;
         r_uac  :  ai_utr(u,3);
        end;

3:   if(ucl_c[false]<10)               // default
     then _unit_straining(u,random(3))
     else
       case race of
       r_hell : begin
                   m:=random(18);
                   if(alrm_r<base_r)or(ucl_c[false]<10)
                   then m:=random(4)
                   else
                   begin
                      if(ucl_e[true,1]<15)then
                       if(ucl_e[false,3]<10)then _unit_straining(u,3);
                      if(_uclord>15)
                      then begin if(ucl_e[false,8]<8 )then _unit_straining(u,8);end
                      else begin if(ucl_e[false,4]<8 )then _unit_straining(u,4);end;
                   end;
                   case m of
                    1,
                    12: if(ai_skill>3)and(ucl_e[true,1]<10)then m:=3;
                    7 : if(ucl_e[false,7]<6)
                        then _unit_straining(u,7)
                        else ai_utr(u,3);
                   else
                    _unit_straining(u,m);
                   end;
                end;
       r_uac  : begin
                   if(g_addon)and(random(2)=0)
                   then _unit_straining(u,9+random(3))
                   else
                   begin
                      if(alrm_r<base_r)or(ucl_c[false]<10)
                      then m:=random(4)
                      else
                      begin
                         if(ucl_e[false,3]<8)then _unit_straining(u,3);
                         if(ucl_e[false,5]<8)then _unit_straining(u,5);
                         if(ucl_e[false,6]<5)then _unit_straining(u,6);
                         if(map_aifly)then _unit_straining(u,11);
                         m:=random(7);
                      end;

                      if(m<2)then
                       if(ucl_e[false,m]>=8)then m:=2+random(4);

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
     if(ucl_x[5]>0)then
     begin
        tu:=@_units[ucl_x[5]];

        u2t:=dist2(x,y,tu^.x,tu^.y)+1;

        if(tu^.buff[ub_advanced]>0)and(tu^.rld_t=0)and(u2t>base_rr)and(alrm_r>base_r)then
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

        if(u2t<tu^.r)and(tu^.rld_t=0)then
        begin
           tu^.uo_x:=(alrm_x-sign(alrm_x-x)*base_r)-randomr(base_r);
           tu^.uo_y:=(alrm_y-sign(alrm_y-y)*base_r)-randomr(base_r);

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
         if(g_mode<>gm_inv)then _unit_supgrade(u,upgr_mainm);
         if(upgr[upgr_vision]=0)then _unit_supgrade(u,upgr_vision);
         if(upgr[upgr_mainr ]=0)or(ucl_e[true,0]<3)then _unit_supgrade(u,upgr_mainr);
         if(u=ucl_x[3])then
          case race of
          r_hell: if(g_addon)then _unit_supgrade(u,upgr_2tier);
          r_uac : if(g_addon)and(random(2)=0)
                  then _unit_supgrade(u,upgr_2tier)
                  else _unit_supgrade(u,upgr_6bld );
          end;
         if(race=r_uac)then _unit_supgrade(u,upgr_plsmt);
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
            if(menerg<100)then _unit_supgrade(u,upgr_bldenrg);
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
           if(alrm_b)and(isbuild=false)then exit;
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

procedure ai_settar(u,tx,ty,tr:integer);
begin
   with _units[u] do
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
   begin
      if(ai_outalrm(u,225,(ai_uc_a=0)and(ai_uc_e>0))=false)then
      begin
         if(alrm_x>0)
         then ai_settar(u,alrm_x  ,alrm_y  ,base_r)
         else ai_target(u);
      end;
   end;
end;

procedure ai_CCOut(u:integer);
begin
   with _units[u] do
   begin
      if(ai_outalrm(u,base_ir,false)=false)then
      begin
          if(ai_bx>0)and(dist2(x,y,ai_bx,ai_by)>base_ir)
          then ai_settar(u,ai_bx,ai_by,base_r)
          else
          begin
             ai_settar(u,x    ,y    ,base_r);
             _unit_action(u);
          end;
      end;
   end;
end;

//procedure

procedure ai_buildingAI(u:integer);
const maxb = 14;
      maxt = 18;
var bucls: TSoB;
    t,
    c_com,
    c_bar,
    c_smt,
    c_twr,
    n_com,
    n_bar,
    n_smt,
    n_twr:integer;
begin
   with _units[u] do
   with _players[player] do
   begin
      bucls:=[ucl_bx5,ucl_bx6,ucl_bx8,ucl_bx9];

      // CCs
      case ai_skill of
      0,1 : n_com:=1;
      2   : n_com:=3;
      3   : n_com:=8;
      4   : n_com:=12;
      else  if(menerg>100)and(race=r_hell)
            then n_com:=12
            else n_com:=16;
      end;
      case race of
      r_hell: c_com:=ucl_e[true,0]+ucl_e[true,12];
      r_uac : c_com:=ucl_e[true,0];
      end;
      if(c_com<n_com)then bucls:=bucls+[ucl_com];

      n_smt:=min3(ai_CheckUpgrs(player),ai_skill,menerg div 11);
      c_smt:=ucl_e[true,3];

      // Bars
      n_bar:=min2(max2(2,(menerg div 6)+n_com-n_smt),maxb);
      case race of
      r_hell: c_bar:=ucl_e[true,1]+ucl_e[true,13];
      r_uac : c_bar:=ucl_e[true,1];
      end;


     { twrs:=ucl_e[true,4 ]
           +ucl_e[true,7 ]
           +ucl_e[true,10];

      case ai_skill of
      0,1 : blds[0]:=1;
      2   : blds[0]:=3;
      3   : blds[0]:=8;
      4   : blds[0]:=12;
      else  if(menerg>100)and(race=r_hell)
            then blds[0]:=12
            else blds[0]:=16;
      end;
      blds[1 ]:=min2(max2(2,(menerg div 6)+ucl_e[true,0]-ucl_e[true,3]),maxb);
      blds[3 ]:=min3(ai_CheckUpgrs(player),ai_skill,menerg div 11);
      blds[4 ]:=min2(ucl_eb[true,0]*4,max2(5,maxt-ucl_eb[true,1]));
      blds[7 ]:=blds[4];
      blds[9 ]:=1;
      blds[10]:=blds[4];

      if(isbuilder)then if(speed=0)then ai_trybuild(x,y,sr,player,uid,(alrm_r<base_rr)and(ai_skill>2),[]);
      if(isbarrack)then ai_utr(u,0);
      if(issmith  )then ai_ups(u);

      twrs:=ucl_eb[true,4]
           +ucl_eb[true,7]
           +ucl_eb[true,10]; }

     { if(ai_skill>1)then
      case uid of
      UID_HKeep : if(hits<1500)and(tar1>0)and(ucl_e[true,0]<3)then
                  begin
                     uo_x:=random(map_mw);
                     uo_y:=random(map_mw);
                     _unit_bteleport(u);
                  end
                  else
                    if(ucl_eb[true,0]>11)and(upgr[upgr_paina]>1)and(ucl_c[false]>40)and(ai_skill>3)then
                    begin
                       uo_x:=alrm_x-randomr(base_r);
                       uo_y:=alrm_y-randomr(base_r);
                       _unit_bteleport(u);
                    end;

      UID_HCommandCenter,
      UID_UCommandCenter:
                  begin
                     case order of
                     0  : if(ucl_e[isbuild,ucl]> 10)
                          then order:=5
                          else order:=4;
                     5  : if(ucl_e[isbuild,ucl]<=10)or(upgr[upgr_ucomatt]=0)then order:=6;
                     6  : if(ucl_e[isbuild,ucl]> 10)then order:=5;
                     else
                     end;

                     case order of
                      6,
                      4: begin
                            if(hits<1500)or(ai_uc_e>5)or(ai_uc_a<3)then
                             if(alrm_r<=sr)and(speed=0)then _unit_action(u);

                            if(speed>0)then
                             if(ucl_e[isbuild,ucl]>8)and(alrm_r<base_rr)and(upgr[upgr_ucomatt]>0)
                             then ai_CCAttack(u)
                             else ai_CCOut(u);
                         end;
                      5: if(speed>0)
                         then ai_CCAttack(u)
                         else
                           if(upgr[upgr_ucomatt]>0)then _unit_action(u);
                      end;
                  end;
      UID_URocketL:
                  if(rld_t=0)and(upgr[upgr_blizz]>0)then
                   if(ai_uc_a<ai_uc_e)and(ai_uc_e>4)then _unit_URocketL(u);
      end;

         if(ai_skill>2)then
         case uid of
          UID_URadar    : if(ai_apcd<32000)then _unit_uradar(u);
          UID_HTotem    : if(upgr[upgr_b478tel]>0)and(alrm_x>0)then
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
          UID_HTower    : if(upgr[upgr_b478tel]>0)and(alrm_x>0)and(sr<alrm_r)and(alrm_r<base_rr)then
                          begin
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
                             if(rld_a>0)then dec(rld_a,1);
                             if(rld_a<=0)or(ai_uc_a>2)or(alrm_r>base_rr)then _unit_kill(u,false,false);
                          end;
          UID_Mine      : begin
                             t:=buff[ub_advanced];
                             if(g_addon=false)or(upgr[upgr_minesen]>0)then
                              if(alrm_r<100)
                              then buff[ub_advanced]:=0
                              else buff[ub_advanced]:=_bufinf;
                             if(alrm_r<base_r)or(t<>buff[ub_advanced])then rld_a:=vid_fps;
                             if(rld_a>0)then dec(rld_a,1);
                             if(rld_a<=0)then _unit_kill(u,false,false);
                          end;
          UID_UWeaponFactory,
          UID_HPools,
          UID_UMilitaryUnit,
          UID_HGate     : if(menerg div 4)>_uclord then _unit_action(u);
         end;

      {$IFDEF _FULLGAME}
      if(menu_s2<>ms2_camp)then
      {$ENDIF}
      case uid of
      UID_HSymbol,
      UID_UGenerator    : if(bld)and(menerg>_ai_get_max_enrg(player,true))then _unit_kill(u,false,false);

      UID_HPools,
      UID_UWeaponFactory: if(ucl_x[3]<>u)and(ai_uprod_status(u)=false)then
                           if(ucl_e[true,3]>blds[3])then _unit_kill(u,false,false);
      UID_UTurret,
      UID_UPTurret,
      UID_URTurret,
      UID_HTower        : if(alrm_r>base_rr)and(twrs>blds[4])then _unit_kill(u,false,false);
      UID_HTotem        : if(buff[ub_invis]=0)then
                           if(alrm_r>base_rr)and(twrs>blds[4])then _unit_kill(u,false,false);
      end;}
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
       if(army>100)or(ucl_c[false]>=ai_maxarmy)then
        if(_uclord>=ai_pushpart)or(apcc>0)
        then order:=2
        else
        begin
           if(g_mode=gm_coop)then order:=2;
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
               r_hell : if(ucl<=3)and(ucl_c[false]>15)then order:=2;
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
                    if(ucl_e[isbuild,ucl]<8)
                    then order:=0
                    else order:=2;

                  if(ai_skill>2)then
                  begin
                     if(uid=UID_Imp)then
                      if(ucl_c[false]>15)
                      then order:=2
                      else
                       if(ucl_e [isbuild,ucl]<8)
                       or(ucl_eb[true,5]=0)
                       then order:=0
                       else order:=2;
                  end;
               end;
            end;
      2   : order:=2;
      end;

      if(order<>2)and(race=r_hell)and(map_aifly)and(uf=uf_ground)then
       if(ucl_x[5]=0)
       then order:=0
       else
         if(ucl>2)and(max>1)then order:=0;

      if(ucl_c[true]=0)or(buff[ub_invuln]>0)then order:=2;

      case g_mode of
      gm_inv : if(player<>0)then order:=0;
      gm_coop: if(player= 0)then
               begin
                  order:=0;
                  if(dist2(x,y,map_psx[0],map_psy[0])>base_ir)and(tar1=0)then
                  begin
                      uo_id :=ua_move;
                      tar1  :=0;
                      tar1d :=32000;
                      alrm_r:=32000;
                  end;
               end;
      end;
   end;
end;

procedure ai_unitAI(u:integer);
var ud: integer;
begin
   with _units[u] do
   with _players[player] do
   begin
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

                  for ud:=0 to _uts do
                   if(ucl_x[ud]>0)then break;

                  if(ud=_uts)
                  then ud:=0
                  else ud:=ucl_x[ud];

                  if(0<ud)and(ud<=MaxUnits)then ai_settar(u,_genx(_units[ud].x,map_mw,false),
                                                            _genx(_units[ud].y,map_mw,false),0);
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
              then with g_ct_pl[ai_pt] do ai_settar(u,px,py,base_r)
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
              then with g_ct_pl[ai_pt] do ai_settar(u,px,py,base_r)
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

      if(ai_skill>2)then
      begin
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
                   if(melee=false)and(alrm_b=false)then ai_outalrm(u,base_r,false);
         UID_LostSoul:
                   begin
                      if(ucl_e[false,0]>10)and(alrm_r=32000)and(g_mode=gm_inv)
                      then _unit_kill(u,false,false)
                      else
                        if(alrm_r<180)and(ai_uc_a<2)then _unit_action(u);
                   end;
         UID_Pain :if(ai_skill>3)then
                   begin
                      if(alrm_r<base_ir)then _unit_action(u);
                      ai_outalrm(u,base_r,false);
                   end;
         UID_Flyer:if(buff[ub_advanced]>0)then
                    if(ai_uc_a<1)then
                     if(ai_ux>0)
                     then ai_settar(u,ai_ux,ai_uy,base_r)
                     else
                       if(ai_bx>0)
                       then ai_settar(u,ai_bx,ai_by,base_r)
                       else ai_outalrm(u,base_rr,false)
                    else
                      if(tar1d<230)then ai_outalrm(u,0,false);
         end;
      end;

      if(race=r_hell)and(alrm_x>0)then ai_useteleport(u);
   end;
end;

procedure _unit_ai1(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;
      uo_bx :=0;

      if(isbuild)
      then ai_buildingAI(u)
      else ;//ai_unitAI(u);

      if(uo_x>map_mw)then uo_x:=map_mw;
      if(uo_y>map_mw)then uo_y:=map_mw;
      if(uo_x<0)then uo_x:=0;
      if(uo_y<0)then uo_y:=0;
   end;
end;


