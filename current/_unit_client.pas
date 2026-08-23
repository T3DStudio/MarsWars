
function unit_UO2Ability(pu:PTUnit;uo:byte):byte;
begin
   unit_UO2Ability:=0;
   with pu^ do
   with uid^ do
     case uo of
     ua_ability1: unit_UO2Ability:=uid_ability1;
     ua_ability2: unit_UO2Ability:=uid_ability2;
     ua_ability3: unit_UO2Ability:=uid_ability3;
     end;
end;

procedure cl_calcWTicks(dataPeriod:byte;pwtickb0,pwtickb1,pwtickb2:pboolean;rpl:boolean);
var wtick:cardinal;
begin
   wtick:=g_tick div dataPeriod;

   pwtickb0^:=(wtick mod cardinal(fr_fps1 div dataPeriod))=0;
   if(rpl)
   then pwtickb1^:=(wtick mod cardinal(fr_fps2 div dataPeriod))=0  // every 2 second
   else pwtickb1^:= pwtickb0^;                                     // every second
   pwtickb2^:=(wtick mod cardinal(fr_fpsd15 div dataPeriod))=0;    // every 8 tick?
end;

////////////////////////////////////////////////////////////////////////////////
//
//   WRITE GAME DATA
//

procedure wudata_byte(bt:byte;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_word(bt:word;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_sint(bt:shortint;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_int(bt:integer;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_lint(bt:longint;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_card(bt:cardinal;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(SizeOf(bt),@bt);
   {$ENDIF}
   false: net_BufferBlock(true,SizeOf(bt),@bt);
   end;
end;

procedure wudata_string(s:shortstring;rpl:boolean);
begin
   case rpl of
   {$IFDEF _FULLGAME}
   true : replay_WriteBlock(length(s)+1,@s);
   {$ENDIF}
   false: net_BufferBlock(true,length(s)+1,@s);
   end;
end;

function wudata_log(p:byte;plog_n_cl:pcardinal;rpl:boolean):boolean;
var
t,s,
i  :cardinal;
b  :byte;
begin
   wudata_log:=false;
   if(p<=LastPlayer)then
     with g_PlayersGame[p] do
     begin
        s:=0;
        if(not rpl)then
        begin
           if(log_n<plog_n_cl^)then
           begin
              plog_n_cl^:=log_n;
              s:=1;
           end;
           if(log_n>plog_n_cl^)then
           begin
              s:=min3c(log_n,log_n-plog_n_cl^,MaxPlayerLog);
              plog_n_cl^:=log_n;
           end;
        end
        else
        begin
           s:=min2c(plog_n_cl^,MaxPlayerLog);
           plog_n_cl^:=0;
        end;

        i:=log_i;
        if(s>0)then
        begin
           if(s>1)then
             for t:=1 to s-1 do
               if(i=0)
               then i:=MaxPlayerLog
               else i-=1;

           wudata_byte(byte(s),rpl);
           while(s>0)do
           begin
              with log_l[i] do
              begin
                 wudata_byte(lm_type,rpl);
                 b:=lm_data_t and %00000011;
                 if(lm_data_u        >0)then b:=b or %00000100;
                 if(length(lm_string)>0)then b:=b or %00001000;
                 if(lm_x             >0)then b:=b or %00010000;
                 wudata_byte(b,rpl);

                 if((b and %00000100)>0)then wudata_byte  (lm_data_u,rpl);
                 if((b and %00001000)>0)then wudata_string(lm_string,rpl);
                 if((b and %00010000)>0)then
                 begin
                    wudata_byte(byte(lm_x shr 5),rpl);
                    wudata_byte(byte(lm_y shr 5),rpl);
                 end;
              end;

              if(i=MaxPlayerLog)
              then i:=0
              else i+=1;
              s-=1;
           end;
           if(not rpl)then wudata_card(plog_n_cl^,rpl);
           wudata_log:=true;
           exit;
        end;
     end;
   wudata_byte(0,rpl);
end;

procedure wudata_PlayersScores(rpl:boolean);
var
p,i,
statb:byte;
begin
   statb:=0;
   for p:=0 to LastPlayer do
     with g_PlayersScore[p] do
       if(ps_state>ps_none)then
         SetBBit(@statb,p,true);

   wudata_byte(statb,rpl);
   if(statb>0)then
     for p:=0 to LastPlayer do
       with g_PlayersScore[p] do
         if(ps_state>ps_none)then
         begin
            wudata_string(ps_name ,rpl);
            wudata_byte  (ps_state,rpl);
            wudata_byte  (ps_race ,rpl);
            wudata_byte  (ps_team ,rpl);

            for i:=0 to psc_Last do wudata_card(ps_data_c[i],rpl);
            for i:=0 to psi_Last do wudata_lint(ps_data_i[i],rpl);
         end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure wudata_StateBits(pu:PTUnit;rpl:boolean);
var byte1,
    byte2,
    byte3:byte;
begin
   with pu^ do
   with uid^ do
   begin
      byte1:=0;
      byte2:=0;
      byte3:=0;

      SetBBit(@byte2,0, buffs[ub_Resurected   ]>0);
      SetBBit(@byte2,1, buffs[ub_Summoned     ]>0);
      SetBBit(@byte2,2, buffs[ub_Teleported   ]>0);
      SetBBit(@byte2,3, buffs[ub_Cast         ]>0);
      SetBBit(@byte2,4, buffs[ub_Scaned       ]>0);
      SetBBit(@byte2,5, buffs[ub_AltMode      ]>0);
      SetBBit(@byte2,6, buffs[ub_PainState    ]>0);
      SetBBit(@byte2,7, buffs[ub_HellVision   ]>0);

      SetBBit(@byte3,0, buffs[ub_SphereInvuln ]>0);
      SetBBit(@byte3,1, buffs[ub_SphereInvis  ]>0);
      SetBBit(@byte3,2, buffs[ub_SphereRDamage]>0);
      SetBBit(@byte3,3, buffs[ub_SphereDDamage]>0);
      SetBBit(@byte3,4, buffs[ub_SphereTurbo  ]>0);
      SetBBit(@byte3,5, buffs[ub_SphereSoul   ]>0);
      SetBBit(@byte3,6, buffs[ub_Heroic       ]>0);
      SetBBit(@byte3,7, transformTimer         >0);

      SetBBit(@byte1,0, iscomplete               );
      SetBBit(@byte1,1, IsUnitRange(transportU,nil));
      SetBBit(@byte1,2,(level and %01)>0         );
      SetBBit(@byte1,3,(level and %10)>0         );
      SetBBit(@byte1,4,(a_tar_cl>0)and(a_rld>0)  );
      SetBBit(@byte1,5, isselected               );
      SetBBit(@byte1,6, byte2>0                  );
      SetBBit(@byte1,7, byte3>0                  );

      wudata_byte(byte1,rpl);
      if(byte2>0)then wudata_byte(byte2,rpl);
      if(byte3>0)then wudata_byte(byte3,rpl);
   end;
end;

function wudata_reload(r:integer;rpl:boolean):byte;
begin
   if(r<=0)
   then wudata_reload:=0
   else wudata_reload:=byte(mm3i(1,(r div fr_fps1)+1,255));
   wudata_byte(wudata_reload,rpl);
end;

procedure wudata_prod(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
   with uid^ do
     for i:=0 to LastUnitLevel do
     begin
        if(i>level)then break;
        if(uid_isbarrack)then if(wudata_reload(uprod_r[i],rpl)>0)then wudata_byte(uprod_u[i],rpl);
        if(uid_isforge  )then if(wudata_reload(pprod_r[i],rpl)>0)then wudata_byte(pprod_u[i],rpl);
     end;
end;

procedure wudata_UnitTar(tar,x,y:pinteger;rpl:boolean);
begin
   if(IsUnitRange(tar^,nil))
   then wudata_int(-tar^,rpl)
   else
   begin
      wudata_int(x^,rpl);
      wudata_int(y^,rpl);
   end;
end;

procedure wudata_UnitOrderTar(pu:PTUnit;uo:byte;rpl:boolean);
begin
   with pu^ do
   with uid^ do
     if(uid_MSpeed_Base>0)
     or(uid_CanAttack)then
     begin
        case uo of
        ua_move,
        ua_amove   : wudata_UnitTar(@uo_tar,@uo_x,@uo_y,rpl);
        ua_patrol,
        ua_apatrol : begin
                        wudata_int(uo_x,rpl);
                        wudata_int(uo_y,rpl);
                     end;
        ua_ability1,
        ua_ability2,
        ua_ability3: with g_aids[unit_UO2Ability(pu,uo)] do
                       if(ua_type=uat_point)then
                       begin
                          wudata_int(uo_x,rpl);
                          wudata_int(uo_y,rpl);
                       end;
        end;
        case uo of
        ua_patrol,
        ua_apatrol : begin
                        wudata_int(uo_bx,rpl);
                        wudata_int(uo_by,rpl);
                     end;
        end;
     end;
end;

procedure wudata_OwnerUData(pu:PTUnit;POVPlayer:byte;rpl:boolean);
var wudtick : pcardinal;
    wudelay : cardinal;
    wb      : boolean;
    b,uo    : byte;
begin
   wb:=false;

   with pu^ do
   with uid^ do
   begin
      case rpl of
      true : begin
                wudtick:=@rpls_wudata_t[unum];
                wudelay:=fr_fpsh;
             end;
      false: begin
                wudtick:=@g_PlayersTemp[POVPlayer].net_wudata_t[unum];
                wudelay:=fr_fpsq;
             end;
      end;

      if(wudtick^>g_tick)
      then wb:=true
      else
        if((g_tick-wudtick^)>=wudelay)
        then wb:=true;

      b:=0;
      if(rpl)
      or(g_PlayersGame[POVPlayer].isobserver)then
        b:=group and %00001111;

      if(not iscomplete)
      or(transformTimer>0)
      then uo:=0
      else
      begin
         uo:=uo_id;
         if(uo_bx>0)then
           case uo_id of
           ua_move : uo:=ua_patrol;
           ua_amove: uo:=ua_apatrol;
           end;
      end;

      b:=b or ((uo and %00000111) shl 4);

      if(wb)then b:=b or %10000000;

      wudata_byte(b,rpl);

      if(not rpl)and(iscomplete)and(transformTimer<=0)then wudata_UnitOrderTar(pu,uo,rpl);

      if(not wb)then exit;

      wudtick^:=g_tick;

      if(iscomplete)and(transformTimer<=0)then
      begin
         if(rpl)then wudata_UnitOrderTar(pu,uo,rpl);
         if(uid_client_WReload)then wudata_reload(rld,rpl);
         if(uid_isbuilding    )then wudata_prod(pu,rpl);
      end;

      if(uid_HaveRallyPoint)then
        if(not rpl or isselected)then
          wudata_UnitTar(@rpoint_tar,@rpoint_x,@rpoint_y,rpl);
   end;
end;

procedure wudata_Unit(pu:PTUnit;rpl:boolean;POVPlayer:byte);
var
hits_si: shortint;
wt     : word;
begin
   with pu^ do
   with uid^ do
   begin
      if(CheckUnitTeamVision(g_PlayersGame[POVPlayer].team,pu,true))
      or(rpl)
      or(g_PlayersGame[POVPlayer].isobserver)
      then hits_si:=hits_li2si(hits,uid_MaxHits1,uid_hits_li2si)
      else hits_si:=-128;

      wudata_sint(hits_si,rpl);
      if(hits_si>-127)then
      begin
         wudata_byte(uidi,rpl);
         wudata_StateBits(pu,rpl);

         if(transportU>0)
         then wudata_int(transportU,rpl)
         else
           if(hits_si>0)then
           begin
              wudata_int(vx ,rpl);
              wudata_int(vy ,rpl);
           end
           else
           begin
              wudata_byte(byte(vx shr 5),rpl);
              wudata_byte(byte(vy shr 5),rpl);
           end;

         if(hits_si>0)then
         begin
            if(iscomplete)then
              if(transformTimer>0)then
              begin
                 wudata_byte(transformUID,rpl);
                 wudata_reload(transformTimer,rpl);
              end
              else
              begin
                 if(a_tar_cl>0)and(a_rld>0)then
                 begin
                    wt:=0;
                    if(IsUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
                    wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
                    wudata_word(wt,rpl);
                 end;
                 if(uid_ability_isradar)and(buffs[ub_Cast]>0)then
                 begin
                    wudata_byte(byte(uo_x shr 5),rpl);
                    wudata_byte(byte(uo_y shr 5),rpl);
                 end;
              end;

            if(playeri=POVPlayer)
            or(g_PlayersGame[POVPlayer].isobserver)then wudata_OwnerUData(pu,POVPlayer,rpl);
         end;
      end;
   end;
end;

procedure wpdata_Upgrades(rpl:boolean;bs_alive:byte);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(GetBBit(@bs_alive,p))then
       begin
          bp:=0;

          for n:=0 to 255 do
            if(race=g_upgrs[n].upgr_race)then
              case bp of
                0: begin
                      bv:=upgrs_cur[n];
                      bp:=1;
                   end;
                1: begin
                      bv:=bv or (upgrs_cur[n] shl 4);
                      wudata_byte(bv,rpl);
                      bp:=0;
                      bv:=0;
                   end;
                end;

            if(bp=1)then wudata_byte(bv,rpl);
       end;
end;

procedure wpdata_BuildCDRes(p:byte;rpl:boolean);
begin
   with g_PlayersGame[p] do
   begin
      wudata_reload(build_cd,rpl);
      wudata_int(res_HellPower,rpl);
      wudata_int(res_UACLoot  ,rpl);
   end;
end;

{function b2bs(b:byte):shortstring;
begin
   b2bs:='00000000';
   if((b and %10000000)>0)then b2bs[1]:='1';
   if((b and %01000000)>0)then b2bs[2]:='1';
   if((b and %00100000)>0)then b2bs[3]:='1';
   if((b and %00010000)>0)then b2bs[4]:='1';
   if((b and %00001000)>0)then b2bs[5]:='1';
   if((b and %00000100)>0)then b2bs[6]:='1';
   if((b and %00000010)>0)then b2bs[7]:='1';
   if((b and %00000001)>0)then b2bs[8]:='1';
end;}

//KeyPointLifeClient

procedure wclinet_KeyPoint(rpl:boolean;POVPlayer:byte);
var
kpteam,
a,b  : byte;
kpt,
w    : word;
wdkpi: pbyte;
function kpLifeTime(lifeSecs:cardinal):word;
begin
   if(lifeSecs=0)
   or(map_GeneratorT=mapg_last)
   then kpLifeTime:=0
   else
   begin
      kpLifeTime:=round(lifeSecs*KeyPointLifeClientCX);
      if(kpLifeTime=0)
      then kpLifeTime:=1
      else
        if(kpLifeTime>=KeyPointLifeClientMax)
        then kpLifeTime:=KeyPointLifeClientMax;
   end;
end;
begin
   if(rpl)
   then wdkpi:=@rpls_kpoints_kpi
   else wdkpi:=@g_PlayersTemp[POVPlayer].net_kpoints_kpi;

   wdkpi^:=(wdkpi^+1) mod map_KeyPointsN;

   if(g_PlayersGame[POVPlayer].isobserver)
   or(rpl)
   then kpteam:=MaxPlayers
   else kpteam:=g_PlayersGame[POVPlayer].team;

   with map_KeyPointsL[wdkpi^] do
     with kp_TeamData[kpteam] do
     begin
        w:=(wdkpi^) and %0000000000011111;
        if(kptd_Active)then w:=w or %0000000000100000;
        if(kptd_Active)then
        begin
           kpt:=kpLifeTime(ct2s(kptd_lifeTime));
           w:=w or ((kpt and %0000001111111111) shl 6);

           wudata_word(w,rpl);

           if(kptd_OwnerPlayer<MaxPlayers)
           then a:=kptd_OwnerPlayer and %00001111
           else a:=%00001111;

           if(kptd_Timer<=0)
           then b:=a
           else
             if(kptd_TimerOwnerPlayer<MaxPlayers)
             then b:=kptd_TimerOwnerPlayer and %00001111
             else b:=%00001111;

           wudata_byte(a or (b shl 4),rpl);

           if(a<>b)then
             wudata_reload(kptd_Timer,rpl);
        end
        else wudata_byte(w and %0000000000111111,rpl);
     end;
end;

procedure wclinet_PlayerCams(POVPlayer:byte;rpl:boolean);
var p,
bs_cam:byte;
begin
   bs_cam:=0;
   for p:=0 to LastPlayer do
     if(p<>POVPlayer)then
       with g_PlayersGame[p] do
       with g_PlayersTemp[p] do
         if(state=ps_human)
         and(not isdefeated)
         and(not isobserver)then
           if(g_PlayersGame[POVPlayer].isobserver)
           or(team=g_PlayersGame[POVPlayer].team)then
             SetBBit(@bs_cam,p,true);

   wudata_byte(bs_cam,rpl);
   if(bs_cam>0)then
     for p:=0 to LastPlayer do
       with g_PlayersTemp[p] do
         if(GetBBit(@bs_cam,p))then
         begin
            wudata_int(cam_x,rpl);
            wudata_int(cam_y,rpl);
            wudata_int(cam_w,rpl);
            wudata_int(cam_h,rpl);
         end;
end;

procedure wclinet_gframe(POVPlayer,dataPeriod:byte;rpl:boolean);
var
wtickb0,
wtickb1,
wtickb2     : boolean;
lastPUnit   : pinteger;
bs_alive,
bs_defeated,
bs_observer,
bs_revealed : byte;
i,
units_ingame,
units_now   : integer;
begin
   wudata_card(g_tick,rpl);

   cl_calcWTicks(dataPeriod,@wtickb0,@wtickb1,@wtickb2,rpl);

   //writeln(g_tick,' ',wtickb0,' ',wtickb1,' ',wtickb2);

   if(rpl)then
   begin
      units_now:=Quality2Units[rpls_Quality];
      lastPUnit:=@rpls_u;
   end
   else
   begin
      units_now:= g_PlayersTemp[POVPlayer].PNU;
      lastPUnit:=@g_PlayersTemp[POVPlayer].n_u;
   end;

   bs_defeated :=255;
   bs_observer :=0;
   bs_revealed :=0;
   for i:=0 to LastPlayer do
     with g_PlayersGame[i] do
       if(state>ps_None)then
       begin
          if(    isrevealed)then SetBBit(@bs_revealed,i,true );
          if(    isobserver)then SetBBit(@bs_observer,i,true );
          if(not isdefeated)then SetBBit(@bs_defeated,i,false);
       end;

   bs_alive    :=0;
   units_ingame:=0;
   for i:=0 to LastPlayer do
     if(not GetBBit(@bs_observer,i))and(not GetBBit(@bs_defeated,i))then
     begin
        SetBBit(@bs_alive,i,true);
        units_ingame+=MaxPlayerUnits;
     end;

   wudata_byte(bs_defeated,rpl);
   wudata_byte(bs_observer,rpl);
   if(bs_alive>0)then
   begin
      if(units_now>255)then units_now:=255;
      wudata_byte(byte(units_now),rpl);

      if(units_now=0)then exit;

      units_now:=min2i(units_ingame,units_now*4);

      if(wtickb2)then
      begin
         if(map_KeyPointsN>0)then
           wclinet_KeyPoint(rpl,POVPlayer);

         if(not rpl)then
           wclinet_PlayerCams(POVPlayer,rpl);
      end;

      if(wtickb0)then
      begin
         if(GetBBit(@bs_alive,POVPlayer))
         then wpdata_BuildCDRes(POVPlayer,rpl)
         else
           if(GetBBit(@bs_observer,POVPlayer))then
             for i:=0 to LastPlayer do
               if(GetBBit(@bs_alive,i))then wpdata_BuildCDRes(i,rpl);

         wpdata_Upgrades(rpl,bs_alive);
         wudata_byte(bs_revealed,rpl);
      end;

      wudata_int(lastPUnit^,rpl);
      for i:=1 to units_now do
      begin
         repeat
            lastPUnit^+=1;
            if (lastPUnit^<1)or(lastPUnit^>MaxUnits)then lastPUnit^:=1;
         until ( bs_alive and (1 shl ((lastPUnit^-1) div MaxPlayerUnits)) ) > 0 ;

         wudata_Unit(@g_units[lastPUnit^],rpl,POVPlayer);
      end;
   end;
end;

{$IFDEF _FULLGAME}

////////////////////////////////////////////////////////////////////////////////
//
//  CLIENT (READ)
//

var
rpoint_ChangeAnnoncer: boolean = false;

u_prev :TUnit;
pu_prev:PTUnit = @u_prev;


procedure client_UnitCountersInc(pu:PTUnit;rpl:boolean);
var i,_puid:byte;
    p:pinteger;
ptransport:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_all_e+=1;
      armylimit+=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_uibtn]+=1;
      units_bld_e[uid_isbuilding          ]+=1;
      units_bld_l[uid_isbuilding          ]+=uid_LimitUse;
      units_uid_e[uidi                    ]+=1;
      if(uid_isbuilder)then units_builders_e+=1;

      ptransport:=nil;
      if(IsUnitRange(transportU,@ptransport))then ptransport^.transportC+=uid_TransportSize;

      if(hits>0)and(ptransport=nil)then
      begin
         if(isselected)and(rpl)then unit_IncCounters_Select(pu);
         if(not iscomplete)
         then res_energyl_cur-=uid_req_EnergyLevel
         else
         begin
            if(transformTimer>0)then
              res_energyl_cur-=g_uids[transformUID].uid_req_EnergyLevel;

            unit_IncCounters_Complete(pu);

            p:=@units_ucl_u[uid_isbuilding,uid_uibtn];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                   if(g_units[p^].uid^.uid_uibtn<>uid_uibtn)then p^:=unum;

            p:=@units_uid_u[uidi];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                   if(g_units[p^].uidi<>uidi)then p^:=unum;

            if(uid_isbarrack)then
              for i:=0 to LastUnitLevel do
                if(uprod_r[i]>0)then
                begin
                   _puid:=uprod_u[i];

                   prod_unit_Limit+=g_uids[_puid].uid_LimitUse;
                   prod_unit_Now  +=1;
                   prod_unit_ucl[g_uids[_puid].uid_uibtn]+=1;
                   prod_unit_uid[       _puid           ]+=1;
                   res_energyl_cur-=g_uids[_puid].uid_req_EnergyLevel;
                end;
            if(uid_isforge)then
              for i:=0 to LastUnitLevel do
                if(pprod_r[i]>0)then
                begin
                   _puid:=pprod_u[i] ;

                   prod_upgr_Now+=1;
                   prod_upgr_upid[_puid]+=1;
                   pprod_e[i]:=upgrade_GetEnergy(_puid,upgrs_cur[_puid]+1);
                   res_energyl_cur-=pprod_e[i];
                end;
         end;
      end;
   end;
end;

procedure client_UnitCountersDec(pu:PTUnit;rpl:boolean);
var i,_puid:byte;
ptransport:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      units_all_e-=1;
      armylimit-=uid_LimitUse;
      units_ucl_e[uid_isbuilding,uid_uibtn]-=1;
      units_bld_e[uid_isbuilding          ]-=1;
      units_bld_l[uid_isbuilding          ]-=uid_LimitUse;
      units_uid_e[uidi                    ]-=1;
      if(uid_isbuilder)then units_builders_e-=1;

      ptransport:=nil;
      if(IsUnitRange(transportU,@ptransport))then ptransport^.transportC-=uid_TransportSize;

      if(hits>0)and(ptransport=nil)then
      begin
         if(isselected)and(rpl)then unit_DecCounters_Select(pu);
         if(not iscomplete)
         then res_energyl_cur+=uid_req_EnergyLevel
         else
         begin
            if(transformTimer>0)then
              res_energyl_cur+=g_uids[transformUID].uid_req_EnergyLevel;

            res_energyl_cur-=uid_gen_EnergyLevel;
            res_energyl_max-=uid_gen_EnergyLevel;
            units_uid_c[uidi]-=1;
            units_ucl_c[uid_isbuilding,uid_uibtn]-=1;
            if(units_ucl_u[uid_isbuilding,uid_uibtn]=unum)then units_ucl_u[uid_isbuilding,uid_uibtn]:=0;
            if(units_uid_u[uidi                    ]=unum)then units_uid_u[uidi                    ]:=0;

            unit_DecCounters_Prod(pu);

            if(uid_isbarrack)then
              for i:=0 to LastUnitLevel do
                if(uprod_r[i]>0)then
                begin
                   _puid:=uprod_u[i];

                   prod_unit_Limit-=g_uids[_puid].uid_LimitUse;
                   prod_unit_Now  -=1;
                   prod_unit_ucl[g_uids[_puid].uid_uibtn]-=1;
                   prod_unit_uid[       _puid           ]-=1;
                   res_energyl_cur+=g_uids[_puid].uid_req_EnergyLevel;
                end;
            if(uid_isforge)then
              for i:=0 to LastUnitLevel do
                if(pprod_r[i]>0)then
                begin
                   _puid:=pprod_u[i];

                   prod_upgr_Now-=1;
                   prod_upgr_upid[_puid]-=1;
                   //pprod_e[i]:=upgrade_GetEnergy(_puid,upgrs_cur[_puid]+1);
                   res_energyl_cur+=pprod_e[i];
                end;
         end;
      end;
   end;
end;


procedure cleffect_UnitSummon(uu:PTUnit;pUIVision:pboolean);
begin
   with uu^ do
   begin
      vx:=x;
      vy:=y;
      effect_UnitSummon(uu,pUIVision);
   end;
end;

procedure cleffect_teleport(cur_u,prev_u:PTUnit;UIVision:boolean);
var sx,sy:integer;
begin
   with cur_u^  do
   begin
      vx:=x;
      vy:=y;
      if(prev_u<>nil)then
      begin
         sx:=prev_u^.vx;
         sy:=prev_u^.vy;
      end
      else
      begin
         sx:=NOTSET;
         sy:=NOTSET;
      end;
      case uidi of
      UID_HKeep : effect_teleport(sx,sy,vx,vy,isfly,EID_HKeep_H ,EID_HKeep_S ,snd_IconOfSinCube,@UIVision,@UIVision);
      UID_HAKeep: effect_teleport(sx,sy,vx,vy,isfly,EID_HAKeep_H,EID_HAKeep_S,snd_IconOfSinCube,@UIVision,@UIVision);
      else        effect_teleport(sx,sy,vx,vy,isfly,EID_Teleport,EID_Teleport,snd_Teleport     ,@UIVision,@UIVision);
      end;
   end;
end;

procedure unit_clear_a_tar(tar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(a_tar=tar)then a_tar:=0;
end;

procedure unit_AddNETVision(pu_cur:PTUnit;POVPlayer:byte;rpl:boolean);
begin
   if(not rpl)and(not g_PlayersGame[POVPlayer].isobserver)then
     with g_PlayersGame[POVPlayer] do
       with pu_cur^ do
         AddToInt(@TeamVision[team],MinVisionTime);
end;

procedure client_ChangeUnitState(pu_cur:PTUnit;POVPlayer:byte;rpl:boolean);
var
tu,
cuTransport:PTUnit;
vis        :boolean;
begin
   // pu_prev - previous state
   // pu_cur - current state
   cuTransport:=nil;
   IsUnitRange(pu_cur^.transportU,@cuTransport);

   if(not rpl)then
     if(pu_prev^.uidi<>pu_cur^.uidi)then
     begin
        unit_UnSelect(pu_prev);
        pu_cur^.group:=0;
        pu_cur^.isselected:=false;
     end
     else
       if(pu_cur^.hits<=0)
       or(cuTransport<>nil)then
       begin
          unit_UnSelect(pu_cur);
          pu_cur^.group:=0;
       end;

   with pu_cur^ do
   with player^ do
     if(pu_prev^.hits<=hits_dead)and(hits>hits_dead)then // create unit
     begin
        unit_SetDefaults(pu_cur,true);
        unit_ApplyUID(pu_cur);
        unit_TeamReveal (pu_cur,true);
        unit_AddNETVision(pu_cur,POVPlayer,rpl);

        vx :=x;
        vy :=y;
        vis:=ui_CheckUnitUIPlayerVision(pu_cur,true)
          or ui_CheckMapPointFogVision(x,y,false);

        if(cuTransport<>nil)then
          unit_InTransportCode(pu_cur,cuTransport);

        unit_Bonuses(pu_cur);

        if(hits>0)then
        begin
           unit_CalcFogR(pu_cur);
           if(buffs[ub_Summoned     ]>0)then cleffect_UnitSummon(pu_cur,             @vis);
           if(buffs[ub_Teleported   ]>0)then cleffect_teleport  (pu_cur,nil         , vis);
           if(buffs[ub_HellVision   ]>0)then   effect_Common    (pu_cur,EID_HVision ,@vis);
           if(buffs[ub_Heroic       ]>0)then   effect_Common    (pu_cur,EID_PowerUp ,@vis);
           if(buffs[ub_SphereInvuln ]>0)
           or(buffs[ub_SphereInvis  ]>0)then   effect_Common    (pu_cur,EID_ULevelUp,@vis);
           if(buffs[ub_SphereRDamage]>0)
           or(buffs[ub_SphereDDamage]>0)
           or(buffs[ub_SphereTurbo  ]>0)then   effect_Common    (pu_cur,EID_HLevelUp,@vis);

           if(playeri=UIPlayer)and(not iscomplete)then
             with uid^ do snd_SoundPlayAnoncer(snd_build_place[uid_race],false,false);

           if(iscomplete)and(buffs[ub_Cast]>0)then
             case uidi of
             UID_URadar    : effect_ScanSound(pu_cur);
             UID_Pain      : if(upgrs_cur[upgr_hell_Phantoms]>0)
                             then unit_ArmSpawnUnit(pu_prev,UID_Phantom )
                             else unit_ArmSpawnUnit(pu_prev,UID_LostSoul);
             end;

           with g_unitsVis[unum] do
             shadowz:= unit_CalcShadowZ(pu_cur,true);
        end;

        missiles_clear_tar(unum,true);
        unit_clear_a_tar(unum);

        client_UnitCountersInc(pu_cur,rpl);
     end
     else
       if(pu_prev^.hits>hits_dead)and(hits<=hits_dead)then // remove unit
       begin
          unit_Bonuses(pu_prev);

          vx:=x;
          vy:=y;
          vis:=ui_CheckUnitUIPlayerVision(pu_cur,true)
            or ui_CheckUnitUIPlayerVision(pu_prev,true);

          if(pu_prev^.hits>0)and(vis)then
          begin
             if(hits>hits_ndead)and(cuTransport=nil)then
             begin
                if(buffs[ub_Teleported]>0)then cleffect_teleport(pu_cur,pu_prev,vis);

                with uid^ do
                  if(uid_isbuilding)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                effect_UnitDeath(pu_cur,true,@vis);
             end;
          end;

          missiles_clear_tar(unum,true);
          unit_clear_a_tar(unum);

          client_UnitCountersDec(pu_prev,rpl);
       end
       else
         if(pu_prev^.hits>hits_dead)and(hits>hits_dead)then    // existed
         begin
            if(pu_prev^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
               missiles_clear_tar(unum,true);
               unit_clear_a_tar(unum);
            end;
            vis:=ui_CheckUnitUIPlayerVision(pu_cur,true)
              or ui_CheckUnitUIPlayerVision(pu_prev,true);

            unit_Bonuses(pu_prev);
            client_UnitCountersDec(pu_prev,rpl);

            unit_Bonuses(pu_cur);
            client_UnitCountersInc(pu_cur,rpl);

            if(hits>0)then
            begin
               case(speed>0)of
               false: if(         buffs[ub_Teleported]> 0)then
                                                   if(pu_prev^.x<>x)or(pu_prev^.y<>y)then cleffect_teleport(pu_cur,pu_prev,vis);
               true : if(pu_prev^.buffs[ub_Teleported]<=0)and(buffs[ub_Teleported]>0)then cleffect_teleport(pu_cur,pu_prev,vis);
               end;
               if (pu_prev^.buffs[ub_Summoned     ]<=0)and(buffs[ub_Summoned     ]>0)then cleffect_UnitSummon(pu_cur,             @vis);
               if (pu_prev^.buffs[ub_PainState    ]<=0)and(buffs[ub_PainState    ]>0)then   effect_UnitPain  (pu_cur,             @vis);
               if (pu_prev^.buffs[ub_HellVision   ]<=0)and(buffs[ub_HellVision   ]>0)then   effect_Common    (pu_cur,EID_HVision ,@vis);
               if (pu_prev^.buffs[ub_Heroic       ]<=0)and(buffs[ub_Heroic       ]>0)then   effect_Common    (pu_cur,EID_PowerUp ,@vis);
               if((pu_prev^.buffs[ub_SphereInvuln ]<=0)and(buffs[ub_SphereInvuln ]>0))
               or((pu_prev^.buffs[ub_SphereInvis  ]<=0)and(buffs[ub_SphereInvis  ]>0))
               or((pu_prev^.buffs[ub_SphereSoul   ]<=0)and(buffs[ub_SphereSoul   ]>0))then  effect_Common    (pu_cur,EID_ULevelUp,@vis);
               if((pu_prev^.buffs[ub_SphereRDamage]<=0)and(buffs[ub_SphereRDamage]>0))
               or((pu_prev^.buffs[ub_SphereDDamage]<=0)and(buffs[ub_SphereDDamage]>0))
               or((pu_prev^.buffs[ub_SphereTurbo  ]<=0)and(buffs[ub_SphereTurbo  ]>0))then  effect_Common    (pu_cur,EID_HLevelUp,@vis);

               if(playeri=UIPlayer)then
               begin
                  if((pu_prev^.iscomplete)and(not iscomplete))
                  or((pu_prev^.transformTimer<=0)and(transformTimer>0))then // start rebuilding/transforming to
                    with uid^ do snd_SoundPlayAnoncer(snd_build_place[uid_race],false,false);

                  if(not pu_prev^.isselected)and(isselected)then ui_UnitSelSound:=true;
               end;

               if(pu_prev^.transportU<>transportU)and(vis)then snd_SoundPlayUnit(snd_Transport,nil,@vis);

               if(iscomplete)then
               begin
                  if(pu_prev^.buffs[ub_Cast]<=0)and(buffs[ub_Cast]>0)then
                    case uidi of
                    UID_URadar    : effect_ScanSound(pu_cur);
                    UID_Pain      : if(upgrs_cur[upgr_hell_Phantoms]>0)
                                    then unit_ArmSpawnUnit(pu_cur,UID_Phantom )
                                    else unit_ArmSpawnUnit(pu_cur,UID_LostSoul);
                    end;
                  if (pu_prev^.transformTimer<=0)
                  and(pu_prev^.level<level)then effect_Common(pu_cur,0,@vis);
               end;
            end;

            if(pu_prev^.hits<=0)and(hits>0)then  //resurrected
            begin
               unit_CalcFogR(pu_cur);
               vx:=x;
               vy:=y;
            end
            else
              if(pu_prev^.hits>0)and(hits<=0)and(buffs[ub_Resurected]=0)then  // death
              begin
                 with uid^ do
                   if(uid_isbuilding)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                 effect_UnitDeath(pu_cur,hits<=hits_fdead,@vis);

                 rld:=0;
              end;

            if(not IsUnitRange(pu_prev^.transportU,nil))then
              if(IsUnitRange(transportU,@tu))then unit_InTransportCode(pu_cur,tu);

            if(speed>0)then
            begin
               move_x:=pu_prev^.x;
               move_y:=pu_prev^.y;
            end;

            if(pu_prev^.x<>x)or(pu_prev^.y<>y)then
            begin
               unit_UpdateXY(pu_cur);

               if(speed>0)then
               begin
                  vstp:=UnitStepTicks;
                  dir :=point_dir(move_px,move_py,x,y);
               end;
               if(speed<=0)or(buffs[ub_Teleported]>0)then
               begin
                  missiles_clear_tar(unum,true);
                  unit_clear_a_tar(unum);
               end;
            end;
         end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function rudata_byte(rpl:boolean;def:byte):byte;
begin
   rudata_byte:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_byte),@rudata_byte);
   false: net_BufferBlock(false,SizeOf(rudata_byte),@rudata_byte);
   end;
end;

function rudata_word(rpl:boolean;def:word):word;
begin
   rudata_word:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_word),@rudata_word);
   false: net_BufferBlock(false,SizeOf(rudata_word),@rudata_word);
   end;
end;

function rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   rudata_sint:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_sint),@rudata_sint);
   false: net_BufferBlock(false,SizeOf(rudata_sint),@rudata_sint);
   end;
end;

function rudata_int(rpl:boolean;def:integer):integer;
begin
   rudata_int:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_int),@rudata_int);
   false: net_BufferBlock(false,SizeOf(rudata_int),@rudata_int);
   end;
end;

function rudata_lint(rpl:boolean;def:longint):longint;
begin
   rudata_lint:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_lint),@rudata_lint);
   false: net_BufferBlock(false,SizeOf(rudata_lint),@rudata_lint);
   end;
end;

function rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   rudata_card:=def;
   case rpl of
   true : replay_ReadBlock(     SizeOf(rudata_card),@rudata_card);
   false: net_BufferBlock(false,SizeOf(rudata_card),@rudata_card);
   end;
end;

function rudata_string(rpl:boolean):shortstring;
var sl:byte;
begin
   rudata_string:='';
   if(not rpl)
   then rudata_string:=net_readstring
   else
   begin
      sl:=rudata_byte(rpl,0);
      while(sl>0)do
      begin
         rudata_string+=chr(rudata_byte(rpl,0));
         sl-=1;
      end;
   end;
end;

{function byte2s(b:byte):shortstring;
begin
   byte2s:='00000000';
   if(b and %00000001)>0 then byte2s[8]:='1';
   if(b and %00000010)>0 then byte2s[7]:='1';
   if(b and %00000100)>0 then byte2s[6]:='1';
   if(b and %00001000)>0 then byte2s[5]:='1';
   if(b and %00010000)>0 then byte2s[4]:='1';
   if(b and %00100000)>0 then byte2s[3]:='1';
   if(b and %01000000)>0 then byte2s[2]:='1';
   if(b and %10000000)>0 then byte2s[1]:='1';
end;   }

procedure  rudata_log(p:byte;rpl:boolean);
var
s,b,
mtype,
argt,
argx,
x,y  :byte;
str  :shortstring;
begin
   s:=rudata_byte(rpl,0);
   if(s>0)then
   begin
      while(s>0)do
      begin
         mtype:=rudata_byte(rpl,0);
         b    :=rudata_byte(rpl,0);

         argt:=0;
         argx:=0;
         str :='';
         x   :=255;
         y   :=255;

         argt:=b and %00000011;
         if((  b and %00000100)>0)then argx:=rudata_byte(rpl,0);
         if((  b and %00001000)>0)then str :=rudata_string(rpl);
         if((  b and %00010000)>0)then
         begin
            x:=rudata_byte(rpl,0);
            y:=rudata_byte(rpl,0);
         end;

         if(x=255)
         then player_LogAdd(p,mtype,argt,argx,str,-1     ,-1     )
         else player_LogAdd(p,mtype,argt,argx,str,x shl 5,y shl 5);

         s-=1;
      end;
      if(not rpl)then
      begin
         net_cl_log_n:=rudata_card(rpl,net_cl_log_n);
         menu_update:=true;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure rudata_PlayersScores(rpl:boolean);
var
p,i,
statb:byte;
begin
   statb:=rudata_byte(rpl,0);
   if(statb>0)then
     for p:=0 to LastPlayer do
       with g_PlayersScore[p] do
         if(GetBBit(@statb,p))then
         begin
            ps_name :=rudata_string(rpl);
            ps_state:=rudata_byte  (rpl,0);
            ps_race :=rudata_byte  (rpl,0);
            ps_team :=rudata_byte  (rpl,0);

            for i:=0 to psc_Last do ps_data_c[i]:=rudata_card(rpl,0);
            for i:=0 to psi_Last do ps_data_i[i]:=rudata_lint(rpl,0);
         end
         else ps_state:=ps_none;
end;

procedure rudata_bstat(uu:PTUnit;POVPlayer:byte;rpl:boolean);
var byte1,
    byte2,
    byte3:byte;
begin
   with uu^ do
   begin
      a_weap:=255;
      level :=0;

      byte1:=rudata_byte(rpl,0);

      iscomplete:=GetBBit(@byte1,0);
      if(GetBBit(@byte1,1))then transportU:=1 else transportU:=0;
      if(GetBBit(@byte1,2))then level+=%01;
      if(GetBBit(@byte1,3))then level+=%10;
      if(GetBBit(@byte1,4))then a_tar:=-1 else a_tar:=0;
      if(rpl)then isselected:=GetBBit(@byte1,5);
      if(GetBBit(@byte1,6))then byte2:=rudata_byte(rpl,0) else byte2:=0;
      if(GetBBit(@byte1,7))then byte3:=rudata_byte(rpl,0) else byte3:=0;

      if(byte2>0)then
      begin
         buffs[ub_Resurected   ]:=buff_Bool2InfTime[GetBBit(@byte2,0)];
         if(GetBBit(@byte2,1))and(buffs[ub_Summoned]<=0)
         then buffs[ub_Summoned]:=fr_fps1;
         buffs[ub_Teleported   ]:=buff_Bool2InfTime[GetBBit(@byte2,2)];
         buffs[ub_Cast         ]:=buff_Bool2InfTime[GetBBit(@byte2,3)];
         buffs[ub_Scaned       ]:=buff_Bool2InfTime[GetBBit(@byte2,4)];
         buffs[ub_AltMode      ]:=buff_Bool2InfTime[GetBBit(@byte2,5)];
         buffs[ub_PainState    ]:=buff_Bool2InfTime[GetBBit(@byte2,6)];
         buffs[ub_HellVision   ]:=buff_Bool2InfTime[GetBBit(@byte2,7)];
      end
      else
      begin
         buffs[ub_Resurected   ]:=0;
         //buffs[ub_Summoned   ]:=0;
         buffs[ub_Teleported   ]:=0;
         buffs[ub_Cast         ]:=0;
         buffs[ub_Scaned       ]:=0;
         buffs[ub_AltMode      ]:=0;
         buffs[ub_PainState    ]:=0;
         buffs[ub_HellVision   ]:=0;
      end;

      if(byte3>0)then
      begin
         buffs[ub_SphereInvuln ]:=buff_Bool2InfTime[GetBBit(@byte3,0)];
         buffs[ub_SphereInvis  ]:=buff_Bool2InfTime[GetBBit(@byte3,1)];
         buffs[ub_SphereRDamage]:=buff_Bool2InfTime[GetBBit(@byte3,2)];
         buffs[ub_SphereDDamage]:=buff_Bool2InfTime[GetBBit(@byte3,3)];
         buffs[ub_SphereTurbo  ]:=buff_Bool2InfTime[GetBBit(@byte3,4)];
         buffs[ub_SphereSoul   ]:=buff_Bool2InfTime[GetBBit(@byte3,5)];
         buffs[ub_Heroic       ]:=buff_Bool2InfTime[GetBBit(@byte3,6)];

         if(GetBBit(@byte3,7))then transformTimer:=1 else transformTimer:=0;
      end
      else
      begin
         buffs[ub_SphereInvuln ]:=0;
         buffs[ub_SphereInvis  ]:=0;
         buffs[ub_SphereRDamage]:=0;
         buffs[ub_SphereDDamage]:=0;
         buffs[ub_SphereTurbo  ]:=0;
         buffs[ub_SphereSoul   ]:=0;
         buffs[ub_Heroic       ]:=0;
         transformTimer         :=0;
      end;

      if(uidi=UID_URMStation)and(buffs[ub_Cast]>0)then
        for byte1:=0 to LastPlayer do
          AddToInt(@TeamVision[byte1],MinVisionTime);

      unit_AddNETVision(uu,POVPlayer,rpl);
   end;
end;

function rudata_reload(r:pinteger;rpl:boolean):byte;
begin
   rudata_reload:=rudata_byte(rpl,0);
   if(rudata_reload=0)
   then r^:=0
   else r^:=rudata_reload*fr_fps1-1;
end;

procedure rudata_prod(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
   with uid^ do
     if(uid_isbuilding)and(iscomplete)then
       for i:=0 to LastUnitLevel do
         if(i<=level)then
         begin
            if(uid_isbarrack)then if(rudata_reload(@uprod_r[i],rpl)>0)then uprod_u[i]:=rudata_byte(rpl,0);
            if(uid_isforge  )then if(rudata_reload(@pprod_r[i],rpl)>0)then pprod_u[i]:=rudata_byte(rpl,0);
         end
         else
         begin
            uprod_r[i]:=0;
            uprod_u[i]:=0;
            pprod_r[i]:=0;
            pprod_u[i]:=0;
         end;
end;

function rudata_UnitTar(tar,x,y:pinteger;rpl:boolean):boolean;
var
i : integer;
tu: PTUnit;
begin
   rudata_UnitTar:=false;
   i:=x^;
   x^:=rudata_int(rpl,0);
   if(i<>x^)then rudata_UnitTar:=true;
   if(IsUnitRange(-x^,@tu))then
   begin
      tar^:=-x^;
      x^  :=tu^.vx;
      y^  :=tu^.vy;
   end
   else
   begin
      i:=y^;
      tar^:=0;
      y^  :=rudata_int(rpl,0);
      if(i<>y^)then rudata_UnitTar:=true;
   end;
end;

procedure rudata_UnitOrderTar(pu:PTUnit;uo:byte;rpl:boolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(uid_MSpeed_Base>0)
      or(uid_CanAttack)then
      begin
         uo_x :=x;
         uo_y :=y;
         uo_bx:=-1;
         uo_by:=-1;

         case uo of
         ua_move,
         ua_amove   : rudata_UnitTar(@uo_tar,@uo_x,@uo_y,rpl);
         ua_patrol,
         ua_apatrol : begin
                         uo_x:=rudata_int(rpl,x);
                         uo_y:=rudata_int(rpl,y);
                      end;
         ua_ability1,
         ua_ability2,
         ua_ability3: with g_aids[unit_UO2Ability(pu,uo)] do
                        if(ua_type=uat_point)then
                        begin
                           uo_x:=rudata_int(rpl,x);
                           uo_y:=rudata_int(rpl,y);
                        end;
         end;
         case uo of
         ua_patrol,
         ua_apatrol : begin
                         uo_bx:=rudata_int(rpl,-1);
                         uo_by:=rudata_int(rpl,-1);
                      end;
         end;
      end;
      case uo of
      ua_patrol  : uo_id:=ua_move;
      ua_apatrol : uo_id:=ua_amove;
      else         uo_id:=uo;
      end;
   end;
end;

procedure rudata_OwnerUData(uu:PTUnit;POVPlayer:byte;rpl:boolean);
var
uo,
b : byte;
begin
   with uu^  do
   with uid^ do
   begin
      b:=rudata_byte(rpl,0);

      if(rpl)
      or(g_PlayersGame[POVPlayer].isobserver)then
        group:=b and %00001111;

      uo:=(b and %01110000)shr 4;

      if(not rpl)and(iscomplete)and(transformTimer<=0)then rudata_UnitOrderTar(uu,uo,rpl);

      if((b and %10000000)=0)then exit;

      if(iscomplete)and(transformTimer<=0)then
      begin
         if(rpl)then rudata_UnitOrderTar(uu,uo,rpl);
         if(uid_client_WReload)then rudata_reload(@rld,rpl);
         if(uid_isbuilding    )then rudata_prod(uu,rpl);
      end;

      if(uid_HaveRallyPoint)then
        if(not rpl or isselected)then
          if(rudata_UnitTar(@rpoint_tar,@rpoint_x,@rpoint_y,rpl))and(rpl)and(playeri=UIPlayer)then rpoint_ChangeAnnoncer:=true;
   end;
end;

procedure rudata_unit(uu:PTUnit;rpl,DEAD:boolean;POVPlayer:byte;fast_skip:boolean);
var sh: shortint;
    i : byte;
    wt: word;
  tmpu: PTUnit;
begin
   if(fast_skip)then
   begin
      tmpu:=uu;
      u_prev.unum:=uu^.unum;
      uu:=pu_prev;
   end
   else u_prev:=uu^;  // 'previous state' of unit

   with uu^ do
   begin
      cycle_order:=unum mod order_period;
      playeri:=(unum-1) div MaxPlayerUnits;
      player :=@g_PlayersGame[playeri];
      if(not DEAD)
      then sh:=rudata_sint(rpl,-128)
      else
        if(hits<hits_dead)
        then sh:=-128
        else sh:=-127;

      if(sh>-127)then
      begin
         i   :=uidi;
         uidi:=rudata_byte(rpl,0);
         if(i<>uidi)then
         begin
            unit_SetDefaults(uu,false);
            unit_ApplyUID(uu);
            FillChar(buffs,SizeOf(buffs),0);
         end;
         hits:=hits_si2li(sh,uid^.uid_MaxHits1,uid^.uid_hits_li2si);
         rudata_bstat(uu,POVPlayer,rpl);

         if(transportU>0)then
         begin
            transportU:=rudata_int(rpl,0);
            if(not IsUnitRange(transportU,nil))then transportU:=0;
         end
         else
           if(sh>0)then
           begin
              x:=rudata_int(rpl,x);
              y:=rudata_int(rpl,y);
           end
           else
           begin
              x:=integer(rudata_byte(rpl,0) shl 5)+(x mod 32);
              y:=integer(rudata_byte(rpl,0) shl 5)+(y mod 32);
           end;

         if(sh>0)then
         begin
            if(iscomplete)then
              if(transformTimer>0)then
              begin
                 transformUID:=rudata_byte(rpl,0);
                 rudata_reload(@transformTimer,rpl);
              end
              else
              begin
                 if(a_tar=-1)then
                 begin
                    wt    :=rudata_word(rpl,0);
                    a_tar :=integer(wt and %0000001111111111);
                    a_weap:=(wt and %1111110000000000) shr 10;
                 end;
                 if(uid^.uid_ability_isradar)and(buffs[ub_Cast]>0)then
                 begin
                    uo_x:=integer(rudata_byte(rpl,0) shl 5);
                    uo_y:=integer(rudata_byte(rpl,0) shl 5);
                 end;
              end;

            if(playeri=POVPlayer)
            or(g_PlayersGame[POVPlayer].isobserver)then rudata_OwnerUData(uu,POVPlayer,rpl);
         end;
      end
      else
        case sh of
        -127: hits:=hits_dead;
        -128: hits:=hits_ndead;
        end;
      if(fast_skip)then
      begin
         vx  :=x;
         vy  :=y;
         vstp:=1;
      end;
   end;
   if(fast_skip)then
   begin
      tmpu^.x :=uu^.x;
      tmpu^.y :=uu^.y;
      tmpu^.vx:=uu^.x;
      tmpu^.vy:=uu^.y;

      unit_UpdateXY(tmpu);
      unit_CalcFogR(tmpu);
   end
   else client_ChangeUnitState(uu,POVPlayer,rpl);
end;


procedure rpdata_Upgrades(rpl:boolean;bs_alive:byte);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(GetBBit(@bs_alive,p))then
       begin
          bp:=0;

          for n:=0 to 255 do
            with g_upgrs[n] do
              if(race=upgr_race)then
              case bp of
              0: begin
                    bv:=rudata_byte(rpl,0);
                    upgrs_cur[n]:=min2i(upgr_max,bv and %00001111);         //???????
                    bp:=1;
                 end;
              1: begin
                    upgrs_cur[n]:=min2i(upgr_max,bv shr 4);
                    bp:=0;
                 end;
              end;
       end;
end;

procedure rpdata_BuildCDRes(p:byte;rpl:boolean);
begin
   with g_PlayersGame[p] do
   begin
     rudata_reload(@build_cd,rpl);
     res_HellPower:=rudata_int(rpl,0);
     res_UACLoot  :=rudata_int(rpl,0);
   end;
end;

procedure rclinet_KeyPoint(rpl,no_effect:boolean);
var
kpi,a,b,
nowner :byte;
w      :word;
pactive:boolean;
function kpLifeTime(lifeSecs:cardinal):word;
begin
   if(lifeSecs=0)
   or(map_GeneratorT=mapg_last)
   then kpLifeTime:=0
   else
   begin
      kpLifeTime:=round(lifeSecs*KeyPointLifeClientXC);
      if(kpLifeTime=0)
      then kpLifeTime:=1
      else
        if(kpLifeTime>=map_generators_LFSecs[map_GeneratorT])
        then kpLifeTime:=map_generators_LFSecs[map_GeneratorT];
   end;
end;
begin
   a  :=rudata_byte(rpl,0);
   kpi:=a and %00011111;

   if(kpi<=LastKeyPoint)then
     with map_KeyPointsL[kpi] do
     with kp_TeamData[MaxPlayers] do
     begin
        pactive:=kptd_Active;
        kptd_Active:=(a and %00100000)>0;
        if(pactive)and(not kptd_Active)then
        begin
           KeyPoint_ChangeOwner(kpi,255,false);
           if(not no_effect)then KeyPoints_Explode(kpi);
        end;

        if(not kptd_Active)then exit;

        b:=rudata_byte(rpl,0);
        w:=word(a) or (b shl 8);
        kptd_lifeTime:=kpLifeTime((w shr 6) and %0000001111111111)*fr_fps1;

        b:=rudata_byte(rpl,0);
        nowner:=b and %00001111;
        KeyPoint_ChangeOwner(kpi,nowner,false);
        kptd_TimerOwnerPlayer:=b shr 4;

        if(kptd_TimerOwnerPlayer<>nowner)
        then rudata_reload(@kptd_Timer,rpl)
        else kptd_Timer:=0;
     end;
end;

procedure rclinet_gframe(POVPlayer,dataPeriod:byte;rpl,fast_skip:boolean);
var
wtickb0,
wtickb1,
wtickb2    : boolean;
bs_observer,
bs_defeated,
bs_alive,
bs         : byte;
i,
units_ingame,
units_now,
lastUnit   : integer;
begin
   rpoint_ChangeAnnoncer:=false;
   g_tick:=rudata_card(rpl,g_tick);

   cl_calcWTicks(dataPeriod,@wtickb0,@wtickb1,@wtickb2,rpl);

   bs_defeated :=rudata_byte(rpl,255);
   bs_observer :=rudata_byte(rpl,0);
   bs_alive    :=0;
   units_ingame:=0;
   for i:=0 to LastPlayer do
     with g_PlayersGame[i] do
     begin
        isobserver:=GetBBit(@bs_observer,i);
        isdefeated:=GetBBit(@bs_defeated,i);
        if(not isobserver)and(not isdefeated)then
        begin
           SetBBit(@bs_alive,i,true);
           units_ingame+=MaxPlayerUnits;
        end;
     end;

   if(bs_alive>0)then
   begin
      units_now:=rudata_byte(rpl,0)*4;

      if(units_now<=0)then exit;

      if(units_now>units_ingame)then units_now:=units_ingame;

      if(units_now<>rpls_pnu)then
      begin
         rpls_pnu:=units_now;
         if(rpls_pnu<=0)then rpls_pnu:=1;
         UnitStepTicks:=round(units_ingame/rpls_pnu*dataPeriod)+1;
         if(UnitStepTicks=0)then UnitStepTicks:=1;
      end;

      if(wtickb2)then
      begin
         if(map_KeyPointsN>0)then
           rclinet_KeyPoint(rpl,fast_skip);

         // player's cam
         if(not rpl)then
         begin
            bs:=rudata_byte(rpl,0);
            for i:=0 to LastPlayer do
              with g_PlayersTemp[i] do
                if(GetBBit(@bs,i))then
                begin
                   cam_x:=rudata_int(rpl,0);
                   cam_y:=rudata_int(rpl,0);
                   cam_w:=rudata_int(rpl,0);
                   cam_h:=rudata_int(rpl,0);
                end
                else
                begin
                   cam_x:=0;
                   cam_y:=0;
                   cam_w:=0;
                   cam_h:=0;
                end;
         end;
      end;

      if(wtickb0)then
      begin
         if(GetBBit(@bs_alive,POVPlayer))
         then rpdata_BuildCDRes(POVPlayer,rpl)
         else
           if(GetBBit(@bs_observer,POVPlayer))then
             for i:=0 to LastPlayer do
               if(GetBBit(@bs_alive,i))then rpdata_BuildCDRes(i,rpl);

         rpdata_Upgrades(rpl,bs_alive);
         bs:=rudata_byte(rpl,0);
         for i:=0 to LastPlayer do
           with g_PlayersGame[i] do
             isrevealed:=GetBBit(@bs,i);
      end;

      lastUnit:=rudata_int(rpl,0);
      for i:=1 to units_now do
      begin
         while(true)do
         begin
            lastUnit+=1;
            if(lastUnit<1)or(lastUnit>MaxUnits)then lastUnit:=1;
            g_units[lastUnit].unum:=lastUnit;
            if( bs_alive and (1 shl ((lastUnit-1) div MaxPlayerUnits)) ) > 0
            then break
            else rudata_unit(@g_units[lastUnit],rpl,true,POVPlayer,fast_skip);
         end;
         rudata_unit(@g_units[lastUnit],rpl,false,POVPlayer,fast_skip);
      end;
   end;

   if(rpoint_ChangeAnnoncer)then
   begin
      if(UIPlayer<=LastPlayer)then
        with g_PlayersGame[UIPlayer] do
          snd_SoundPlayUnitCommand(snd_rally_point[race]);
      rpoint_ChangeAnnoncer:=false;
   end;
end;
{$ENDIF}


