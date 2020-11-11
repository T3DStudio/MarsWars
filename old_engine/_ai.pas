
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
             _bc_ss(@a_build,[]);
             _bc_ss(@a_units,[]);
             _bc_ss(@a_upgr ,[]);

             ai_pushtime := vid_fps;
             ai_towngrd  := 100;
             ai_maxunits := 0;
             ai_pushmin  := 0;
          end;
      1 : begin
             _bc_ss(@a_build,[0..2]);
             _bc_ss(@a_units,[0..2]);
             _bc_ss(@a_upgr ,[    ]);

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 9;
             ai_maxunits := 10;
             ai_pushmin  := ai_maxunits-5;
          end;
      2 : begin  // ITYTD
             _bc_ss(@a_build,[0..3]);
             case race of
             r_hell: _bc_ss(@a_units,[0..3  ]);
             r_uac : _bc_ss(@a_units,[0..3,7]);
             end;
             _bc_ss(@a_upgr ,[0..5,6]);

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 17;
             ai_maxunits := 25;
             ai_pushmin  := ai_maxunits-5;
          end;
      3 : begin  // HNTR
             _bc_ss(@a_build,[0..6]);
             case race of
             r_hell: _bc_ss(@a_units,[0..4  ]);
             r_uac : _bc_ss(@a_units,[0..4,7]);
             end;
             _bc_ss(@a_upgr ,[0..upgr_2tier-1]);

             ai_pushtime := vid_fps*240;
             ai_towngrd  := 20;
             ai_maxunits := 35;
             ai_pushmin  := ai_maxunits-5;
          end;
      4 : begin  // HMP
             _bc_ss(@a_build,[0..7,9]);
             case race of
             r_hell: _bc_ss(@a_units,[0..5,8..10]);
             r_uac : _bc_ss(@a_units,[0..9      ]);
             end;
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             ai_pushtime := vid_fps*180;
             ai_towngrd  := 10;
             ai_maxunits := 45;
             ai_pushmin  := ai_maxunits-5;
          end;
      5 : begin  // UV
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);
             ai_pushtime := vid_fps*60;
          end;
      6 : begin  // Nightmare
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr],race,1);
          end;
      7 : begin  // Super Nightmare
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld],race,1);
          end;
      8 : begin  // HELL
             _bc_ss(@a_build,[0..14]);
             _bc_ss(@a_units,[0..11]);
             _bc_ss(@a_upgr ,[0..MaxUpgrs]);

             _upgr_ss(@upgr ,[upgr_mainr,upgr_advbld,upgr_advbar],race,1);
          end;
      250:begin // assault AI
            _bc_ss(@a_build,[]);
            _bc_ss(@a_units,[]);
            _bc_ss(@a_upgr ,[]);

            ai_pushtime := vid_fps;
            ai_towngrd  := 100;
            ai_maxunits := 0;
            ai_pushmin  := 0;

            ai_flags:=aif_unitaacts+aif_detecatcs+aif_smarttpri+aif_stayathome;

            _upgr_ss(@upgr ,[0..MaxUpgrs],race,10);
            exit;
          end;
      else
         a_build:=0;
         a_units:=0;
         a_upgr :=0;
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
          0,1  : _bc_sa(@a_units,[12    ]);
          2    : _bc_sa(@a_units,[12..13]);
          3    : _bc_sa(@a_units,[12..15]);
            else _bc_sa(@a_units,[12..18]);
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
   with _players[playern] do
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
    with _players[playern] do
     case uid of
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
   with _players[playern] do
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
                 if(teams=false)
                 then inc(ai_uc_e,1)
                 else
                   if(tu^.uid=UID_Mine)then inc(ai_uc_a,1);
      UID_HCommandCenter,
      UID_UCommandCenter:
                begin
                   if(uid_x[uid]=unum)and(tu^.uid=uid)then
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
                    or((tu^.uid=uid)and(tu^.speed>0)and(upgr[upgr_ucomatt]>0))then
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
   with _players[playern] do
   begin
      ai_cnt_blds(pu,tu);

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
          if(tu^.uid=UID_UVehicleFactory)and(buff[ub_advanced]=0)and(tu^.buff[ub_advanced]>0)and(tu^.rld_t=0)and(ud<base_rr)and(alrm_r>base_r)then
          begin
             order:=1;
             uo_x :=tu^.x;
             uo_y :=tu^.y;
             if(ud<melee_r)then _unit_UACUpgr(pu,tu);
          end;

         if(race=r_hell)then
          case uid of
          UID_HMonastery:
            if(cf(@ai_flags,@aif_usex6))then
            if(tu^.uid in demons)and(tu^.buff[ub_advanced]=0)and(upgr[upgr_6bld]>0)and(tu^.isbuild=false)then
            begin
               if(tu^.uid=UID_LostSoul)and(ucl_e[false,7]>0)then exit;
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
                if(tu^.ucl<2)or(tu^.uid in [UID_Pain,UID_ZFormer])then exit;
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
      if not(cl2uid[race,true,ucl] in uids_builder[builderuid])then exit;
      if(ucl_e[true,ucl]>=cnt)then exit;
   end;
   if(_bldCndt(bp,ucl))then exit;
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
    with _players[playern] do
     if((ucl_e[false,_ucl]+uprodc[_ucl])<cnt)then _unit_straining(pu,_ucl);
end;

procedure ai_utr(pu:PTUnit;m:integer);
begin
   with pu^ do
   with _players[playern] do
   if(ucl_c[false]<ai_maxunits)then
   begin
      if(uid=UID_HMilitaryUnit)then
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
    with _players[playern] do
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
   with _players[playern] do
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
      if(upgr[npt]<ai_upgrlvl(playern,npt))then _unit_supgrade(pu,npt);
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
   with _players[playern] do
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
      n_smt:=max2(1,min3(ai_CheckUpgrs(playern),ai_skill,menerg div 11));
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
        (speed  =0)then ai_trybuild(x,y,sr,playern,uid,(alrm_r<base_rr)and(cf(@ai_flags,@aif_alrmtwrs)),@bucls);
      if(isbarrack)then ai_utr(pu,0);
      if(issmith  )then ai_upgrs(pu);

      case uid of
UID_HKeep :
         if(hits<1500)and(tar1>0)and(uid_e[uid]<3)then
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
            if(uid_eb[uid]>11)and(upgr[upgr_paina]>1)and(ucl_c[false]>40)then
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
      case uid of
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
      case uid of
UID_HEye:
         begin
            if(alrm_r<base_r)then rld_a:=vid_fps;
            if(rld_a>0)then dec(rld_a,1);
            if(rld_a<=0)or(ai_uc_a>2)or(alrm_r>base_rr)then _unit_kill(pu,false,false);
         end;
UID_Mine:
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
      case uid of
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
      case uid of
UID_HSymbol,
UID_UGenerator:
         if(bld)and(menerg>_ai_get_max_enrg(playern,true))then _unit_kill(pu,false,false);
UID_UMilitaryUnit,
UID_HMilitaryUnit,
UID_HGate:
         if(uid_x[uid]<>unum)and(bld)and(ai_uprod_status(pu)=false)then
          if(ai_uprods>n_bar)then _unit_kill(pu,false,false);
UID_HPools,
UID_UWeaponFactory:
         if(uid_x[uid]<>unum)and(ai_uprod_status(pu)=false)then
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
   with _players[playern] do
   begin
      if(inapc>0)then
      begin
         ai_deforder(@_units[inapc]);
         order:=2;
         exit;
      end;

      if(cf(@ai_flags,@aif_pushuids))then
       if not(uid in ai_pushuids)then exit;

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
   with _players[playern] do
   begin
      if(ai_pushfrmi>0)then
       if(cf(@ai_flags,@aif_dattack))then ai_deforder(pu);

      if(cf(@ai_flags,@aif_hrrsmnt))then
      begin
         case uid of
UID_LostSoul : order:=2;
UID_Imp,
UID_Demon    : if(uid_eb[uid]>5)then order:=3;
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
   with _players[playern] do
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

      case uid of
      UID_Major,
      UID_ZMajor: if(uf=uf_ground)then _unit_action(pu);
      end;

      case uid of
UID_Engineer:if(alrm_r<=sr)then
             begin
                if(cf(@ai_flags,@aif_unitaacts))then
                 if(melee=false)and(buff[ub_advanced]=0)and(alrm_b=false)then ai_outalrm(pu,0,false,false);
                if(cf(@ai_flags,@aif_detecatcs))then
                 if(uid=UID_Engineer)and(ai_uc_a<1)then _unit_action(pu);
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
      case uid of
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
   with _players[playern] do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;
      uo_bx :=-1;

      if(isbuild)
      then ai_buildingAI(pu)
      else ai_unitAI(pu);

      if(uo_x>map_mw)then uo_x:=map_mw;
      if(uo_y>map_mw)then uo_y:=map_mw;
      if(uo_x<0)then uo_x:=0;
      if(uo_y<0)then uo_y:=0;
   end;
end;


