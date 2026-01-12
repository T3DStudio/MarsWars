
const

kpdata_owner  = %10000000;
kpdata_timer  = %11000000;
kpdata_life   = %01000000;

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
     with g_gplayers[p] do
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

      SetBBit(@byte3,0, buffs[ub_SphereInvuln ]>0);
      SetBBit(@byte3,1, buffs[ub_SphereInvis  ]>0);
      SetBBit(@byte3,2, buffs[ub_SphereRDamage]>0);
      SetBBit(@byte3,3, buffs[ub_SphereDDamage]>0);
      SetBBit(@byte3,4, buffs[ub_SphereTurbo  ]>0);
      SetBBit(@byte3,5, buffs[ub_Heroic       ]>0);
      SetBBit(@byte3,6, buffs[ub_HellVision   ]>0);

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

procedure wudata_UnitOrderTar(pu:PTUnit;uo:byte;rpl:boolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(uid_client_WCastTarget)then
        if(buffs[ub_Cast]>0)then exit;

      case uo of
      ua_move,
      ua_amove,
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

procedure wudata_OwnerUData(pu:PTUnit;rpl:boolean);
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
                wudtick:=@net_wudata_t [unum];
                wudelay:=fr_fpsq;
             end;
      end;

      if(wudtick^>g_tick)
      then wb:=true
      else
        if((g_tick-wudtick^)>=wudelay)
        then wb:=true;

      b:=group and %00001111;

      if(iscomplete)
      then uo:=uo_id
      else uo:=0;
      if(uo_bx>0)then
        case uo_id of
        ua_move : uo:=ua_patrol;
        ua_amove: uo:=ua_apatrol;
        end;

      b:=b or ((uo and %00000111) shl 4);

      if(wb)then b:=b or %10000000;

      wudata_byte(b,rpl);

      if(not rpl)and(iscomplete)then wudata_UnitOrderTar(pu,uo,rpl);

      if(not wb)then exit;

      wudtick^:=g_tick;

      if(iscomplete)then
      begin
         if(rpl)then wudata_UnitOrderTar(pu,uo,rpl);
         if(uid_client_WReload)then wudata_reload(rld,rpl);
         if(uid_isbuilding    )then wudata_prod(pu,rpl);
      end;

      if(uid_HaveRallyPoint and(isselected or not rpl))then
        if(IsUnitRange(rpoint_tar,nil))
        then wudata_int(-rpoint_tar,rpl)
        else
        begin
           wudata_int(rpoint_x,rpl);
           wudata_int(rpoint_y,rpl);
        end;
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
      if(CheckUnitTeamVision(g_gplayers[POVPlayer].team,pu,true))or(rpl)or(g_gplayers[POVPlayer].isobserver)
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
            begin
               if(a_tar_cl>0)and(a_rld>0)then
               begin
                  wt:=0;
                  if(IsUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
                  wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
                  wudata_word(wt,rpl);
               end;

               if(uid_client_WCastTarget)then
                 if(buffs[ub_Cast]>0)then
                 begin
                    wudata_byte(byte(uo_x shr 5),rpl);
                    wudata_byte(byte(uo_y shr 5),rpl);
                 end;
            end;

            if(playeri=POVPlayer)
            or(g_gplayers[POVPlayer].isobserver)then wudata_OwnerUData(pu,rpl);
         end;
      end;
   end;
end;

procedure wpdata_Upgrades(rpl:boolean;bs_alive:byte);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(GetBBit(@bs_alive,p))then
       begin
          bp:=0;

          for n:=0 to 255 do
            if(race=g_upids[n].upgr_race)then
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
   with g_gplayers[p] do
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

procedure wclinet_KeyPoint(rpl:boolean;POVPlayer:byte);
var
kpteam,
a,b  : byte;
w    : word;
wdkpi: pbyte;
begin
   if(rpl)
   then wdkpi:=@rpls_kpoints_kpi
   else wdkpi:= @net_kpoints_kpi;

   wdkpi^:=(wdkpi^+1) mod MaxKeyPoints;

   if(g_gplayers[POVPlayer].isobserver)
   then kpteam:=MaxPlayers
   else kpteam:=g_gplayers[POVPlayer].team;

   with map_KeyPointsL[wdkpi^] do
     with kp_TeamData[kpteam] do
     begin
        {a:=wdkpi^ and %00001111;
        if(kptd_Active)then
        a:=a or %00010000;
        wudata_byte(a,rpl); }

        w:=(wdkpi^) and %0000000000001111;
        if(kptd_Active)then w:=w or %0000000000010000;
        if(kptd_Active)then
        begin
           w:=w or ((word(ct2s(kptd_lifeTime)) and %0000011111111111) shl 5);
           wudata_word(w,rpl);

           if(kptd_OwnerPlayer>=MaxPlayers)
           then a:=%00001111
           else a:=kptd_OwnerPlayer;

           if(kptd_TimerOwnerPlayer>=MaxPlayers)
           then b:=%1111
           else b:=(kptd_TimerOwnerPlayer and %00001111) shl 4;

           a:=a or b;
           wudata_byte(a,rpl);
        end
        else wudata_byte(w and %0000000000011111,rpl);
     end;
   {
   kpi
   kptd_Active
   kptd_lifeTime
   kptd_OwnerPlayer
   kptd_TimerOwnerPlayer}
end;

procedure wclinet_gframe(POVPlayer:byte;rpl:boolean);
var
wtick       : cardinal;
wtickb0,
wtickb1     : boolean;
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

   wtick:=g_tick shr 1;

   wtickb0:=(wtick mod fr_fpsh)=0;
   if(rpl)
   then wtickb1:=(wtick mod fr_fps1)=0  // every 2 second
   else wtickb1:= wtickb0;              // every second

   if(wtickb1)then
     case map_scenario of
     mc_royale   : wudata_int(g_royal_r,rpl);
     end;

   if(rpl)then
   begin
      units_now:=Quality2Units[rpls_Quality];
      lastPUnit:=@rpls_u;
   end
   else
   begin
      units_now:= g_nplayers[POVPlayer].PNU;
      lastPUnit:=@g_nplayers[POVPlayer].n_u;
   end;

   bs_defeated :=255;
   bs_observer :=0;
   bs_revealed :=0;
   for i:=0 to LastPlayer do
     with g_gplayers[i] do
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

      if(map_scenario=mc_KeyPoints)
      or(map_scenario=mc_KotH)
      or(map_generators>0)then
        wclinet_KeyPoint(rpl,POVPlayer);

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
                   pprod_e[i]:=GetUpgradeEnergy(_puid,upgrs_cur[_puid]+1);
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
                   prod_unit_Now-=1;
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
                   //pprod_e[i]:=GetUpgradeEnergy(_puid,upgrs_cur[_puid]+1);
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

procedure cleffect_teleport(uu,pu:PTUnit);
begin
   with uu^  do
   begin
      vx:=x;
      vy:=y;
      case uidi of
      UID_HKeep : effect_teleport(pu^.vx,pu^.vy,vx,vy,isfly,EID_HKeep_H ,EID_HKeep_S ,snd_IconOfSinCube,uu);
      UID_HAKeep: effect_teleport(pu^.vx,pu^.vy,vx,vy,isfly,EID_HAKeep_H,EID_HAKeep_S,snd_IconOfSinCube,uu);
      else        effect_teleport(pu^.vx,pu^.vy,vx,vy,isfly,EID_Teleport,EID_Teleport,snd_Teleport     ,uu);
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

procedure client_ChangeUnitState(cu:PTUnit;rpl:boolean);
var
pu,tu,
cuTransport:PTUnit;
   vis:boolean;
begin
   // pu - previous state
   // cu - current state
   pu:=@g_units[0];
   cuTransport:=nil;
   IsUnitRange(cu^.transportU,@cuTransport);

   if(not rpl)then
     if(pu^.uidi<>cu^.uidi)then
     begin
        unit_UnSelect(pu);
        cu^.group:=0;
        cu^.isselected:=false;
     end
     else
       if(cu^.hits<=0)
       or(cuTransport<>nil)then
       begin
          unit_UnSelect(cu);
          cu^.group:=0;
       end;

   with cu^ do
   with player^ do
     if(pu^.hits<=hits_dead)and(hits>hits_dead)then // create unit
     begin
        unit_SetDefaults(cu,true);
        unit_TeamReveal (cu,true);
        vx :=x;
        vy :=y;
        vis:=ui_CheckUnitUIPlayerVision(cu,true);

        if(cuTransport<>nil)then
          unit_InTransportCode(cu,cuTransport);

        unit_Bonuses(cu);

        if(hits>0)then
        begin
           unit_CalcFogR(cu);
           if(buffs[ub_Summoned     ]>0)then cleffect_UnitSummon(cu,             @vis);
           if(buffs[ub_Teleported   ]>0)then cleffect_teleport  (cu,             @vis);
           if(buffs[ub_HellVision   ]>0)then   effect_Common    (cu,EID_HVision ,@vis);
           if(buffs[ub_Heroic       ]>0)then   effect_Common    (cu,EID_PowerUp ,@vis);
           if(buffs[ub_SphereInvuln ]>0)
           or(buffs[ub_SphereInvis  ]>0)then   effect_Common    (cu,EID_ULevelUp,@vis);
           if(buffs[ub_SphereRDamage]>0)
           or(buffs[ub_SphereDDamage]>0)
           or(buffs[ub_SphereTurbo  ]>0)then   effect_Common    (cu,EID_HLevelUp,@vis);

           if(playeri=UIPlayer)and(not iscomplete)then
             with uid^ do snd_SoundPlayAnoncer(snd_build_place[uid_race],false,false);
        end;

        missiles_clear_tar(unum,true);
        unit_clear_a_tar(unum);

        client_UnitCountersInc(cu,rpl);
     end
     else
       if(pu^.hits>hits_dead)and(hits<=hits_dead)then // remove unit
       begin
          unit_Bonuses(pu);

          vx:=x;
          vy:=y;
          vis:=ui_CheckUnitUIPlayerVision(cu,true);

          if(pu^.hits>0)and(vis)then
          begin
             if(hits>hits_ndead)and(cuTransport=nil)then
             begin
                if(buffs[ub_Teleported]>0)then cleffect_teleport(cu,@vis);

                with uid^ do
                  if(uid_isbuilding)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                effect_UnitDeath(cu,true,@vis);
             end;
          end;

          missiles_clear_tar(unum,true);
          unit_clear_a_tar(unum);

          client_UnitCountersDec(pu,rpl);
       end
       else
         if(pu^.hits>hits_dead)and(hits>hits_dead)then    // existed
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
               missiles_clear_tar(unum,true);
               unit_clear_a_tar(unum);
            end;
            vis:=ui_CheckUnitUIPlayerVision(cu,true);

            unit_Bonuses(pu);
            client_UnitCountersDec(pu,rpl);

            unit_Bonuses(cu);
            client_UnitCountersInc(cu,rpl);

            if(hits>0)then
            begin
               case(speed>0)of
               false: if(    buffs[ub_Teleported]> 0)then if(pu^.x<>x)or(pu^.y<>y)then cleffect_teleport(cu,pu);
               true : if(pu^.buffs[ub_Teleported]<=0)  and(buffs[ub_Teleported]>0)then cleffect_teleport(cu,pu);
               end;
               if (pu^.buffs[ub_Summoned     ]<=0)and(buffs[ub_Summoned     ]>0)then cleffect_UnitSummon(cu,             @vis);
               if (pu^.buffs[ub_PainState    ]<=0)and(buffs[ub_PainState    ]>0)then   effect_UnitPain  (cu,             @vis);
               if (pu^.buffs[ub_HellVision   ]<=0)and(buffs[ub_HellVision   ]>0)then   effect_Common    (cu,EID_HVision ,@vis);
               if (pu^.buffs[ub_Heroic       ]<=0)and(buffs[ub_Heroic       ]>0)then   effect_Common    (cu,EID_PowerUp ,@vis);
               if((pu^.buffs[ub_SphereInvuln ]<=0)and(buffs[ub_SphereInvuln ]>0))
               or((pu^.buffs[ub_SphereInvis  ]<=0)and(buffs[ub_SphereInvis  ]>0))then  effect_Common    (cu,EID_ULevelUp,@vis);
               if((pu^.buffs[ub_SphereRDamage]<=0)and(buffs[ub_SphereRDamage]>0))
               or((pu^.buffs[ub_SphereDDamage]<=0)and(buffs[ub_SphereDDamage]>0))
               or((pu^.buffs[ub_SphereTurbo  ]<=0)and(buffs[ub_SphereTurbo  ]>0))then  effect_Common    (cu,EID_HLevelUp,@vis);

               if(playeri=UIPlayer)then
               begin
                  if(pu^.iscomplete)and(not iscomplete)then // start transforming to
                    with uid^ do snd_SoundPlayAnoncer(snd_build_place[uid_race],false,false);
                  if(not pu^.isselected)and(isselected)then ui_UnitSelSound:=true;
               end;

               if(pu^.transportU<>transportU)and(vis)then snd_SoundPlayUnit(snd_Transport,nil,@vis);

               if(iscomplete)then
               begin
                  if(pu^.buffs[ub_Cast]<=0)and(buffs[ub_Cast]>0)then
                    case uidi of
                    UID_URadar    : effect_ScanSound(cu);
                    UID_URMStation: unit_UACStrike_missile(cu);
                    UID_Pain      : if(upgrs_cur[upgr_hell_Phantoms]>0)
                                     then unit_ArmSpawnUnit(pu,UID_Phantom )
                                     else unit_ArmSpawnUnit(pu,UID_LostSoul);
                    end;
                  if(pu^.level<level)then effect_Common(cu,0,@vis);
               end;
            end;

            if(pu^.hits<=0)and(hits>0)then  //resurrected
            begin
               unit_CalcFogR(cu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buffs[ub_Resurected]=0)then  // death
              begin
                 with uid^ do
                   if(uid_isbuilding)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                 effect_UnitDeath(cu,hits<=hits_fdead,@vis);

                 rld:=0;
              end;

            if(not IsUnitRange(pu^.transportU,nil))then
              if(IsUnitRange(transportU,@tu))then unit_InTransportCode(cu,tu);

            if(speed>0)then
            begin
               move_x:=pu^.x;
               move_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               unit_UpdateXY(cu);

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

function byte2s(b:byte):shortstring;
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
end;

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
         then PlayerAddLog(p,mtype,argt,argx,str,-1     ,-1     )
         else PlayerAddLog(p,mtype,argt,argx,str,x shl 5,y shl 5);

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
      end;

      if(byte3>0)then
      begin
         buffs[ub_SphereInvuln ]:=buff_Bool2InfTime[GetBBit(@byte3,0)];
         buffs[ub_SphereInvis  ]:=buff_Bool2InfTime[GetBBit(@byte3,1)];
         buffs[ub_SphereRDamage]:=buff_Bool2InfTime[GetBBit(@byte3,2)];
         buffs[ub_SphereDDamage]:=buff_Bool2InfTime[GetBBit(@byte3,3)];
         buffs[ub_SphereTurbo  ]:=buff_Bool2InfTime[GetBBit(@byte3,4)];
         buffs[ub_Heroic       ]:=buff_Bool2InfTime[GetBBit(@byte3,5)];
         buffs[ub_HellVision   ]:=buff_Bool2InfTime[GetBBit(@byte3,6)];
      end
      else
      begin
         buffs[ub_SphereInvuln ]:=0;
         buffs[ub_SphereInvis  ]:=0;
         buffs[ub_SphereRDamage]:=0;
         buffs[ub_SphereDDamage]:=0;
         buffs[ub_SphereTurbo  ]:=0;
         buffs[ub_Heroic       ]:=0;
         buffs[ub_HellVision   ]:=0;
      end;

      if(not rpl)and(not g_gplayers[POVPlayer].isobserver)then
        with g_gplayers[POVPlayer] do
          AddToInt(@TeamVision[team],MinVisionTime);
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

procedure rudata_UnitOrderTar(pu:PTUnit;uo:byte;rpl:boolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(uid_client_WCastTarget)then
        if(buffs[ub_Cast]>0)then exit;

      uo_x :=x;
      uo_y :=y;
      uo_bx:=-1;
      uo_by:=-1;

      case uo of
      ua_move,
      ua_amove,
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
      case uo of
      ua_patrol  : uo_id:=ua_move;
      ua_apatrol : uo_id:=ua_amove;
      else         uo_id:=uo;
      end;
   end;
end;

procedure rudata_OwnerUData(uu:PTUnit;rpl:boolean);
var
uo,
b : byte;
i : integer;
tu: PTUnit;
begin
   with uu^  do
   with uid^ do
   begin
      b:=rudata_byte(rpl,0);

      group:= b and %00001111;
      uo   :=(b and %01110000)shr 4;

      if(not rpl)and(iscomplete)then rudata_UnitOrderTar(uu,uo,rpl);

      if((b and %10000000)=0)then exit;

      if(iscomplete)then
      begin
         if(rpl)then rudata_UnitOrderTar(uu,uo,rpl);
         if(uid_client_WReload)then rudata_reload(@rld,rpl);
         if(uid_isbuilding    )then rudata_prod(uu,rpl);
      end;

      if(uid_HaveRallyPoint and(isselected or not rpl))then
      begin
         i:=rpoint_x;
         rpoint_x:=rudata_int(rpl,0);
         if(i<>rpoint_x)and(rpl)and(playeri=UIPlayer)then rpoint_ChangeAnnoncer:=true;
         if(IsUnitRange(-rpoint_x,@tu))then
         begin
            rpoint_tar:=-rpoint_x;
            rpoint_x  :=tu^.vx;
            rpoint_y  :=tu^.vy;
         end
         else
         begin
            i:=rpoint_y;
            rpoint_tar:=0;
            rpoint_y  :=rudata_int(rpl,0);
            if(i<>rpoint_y)and(rpl)and(playeri=UIPlayer)then rpoint_ChangeAnnoncer:=true;
         end;
      end;
   end;
end;

procedure rudata_unit(uu:PTUnit;rpl,DEAD:boolean;POVPlayer:byte;fast_skip:boolean);
var sh: shortint;
    i : byte;
    wt: word;
    ou: PTUnit;
begin
   if(fast_skip)then
   begin
      ou:=uu;
      g_units[0].unum:=uu^.unum;
      uu:=@g_units[0];
   end
   else g_units[0]:=uu^;

   with uu^ do
   begin
      cycle_order:=unum mod order_period;
      playeri:=(unum-1) div MaxPlayerUnits;
      player :=@g_gplayers[playeri];
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
            unit_ApplyUID(uu);
            unit_SetDefaults(uu,false);
            FillChar(buffs,SizeOf(buffs),0);
         end;
         hits:=hits_si2li(sh,uid^.uid_MaxHits1,uid^.uid_hits_li2si);
         rudata_bstat(uu,POVPlayer,rpl);

         if(transportU>0)then
         begin
            transportU:=rudata_int(rpl,0);
            if(IsUnitRange(transportU,nil)=false)then transportU:=0;
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
            begin
               if(a_tar=-1)then
               begin
                  wt    :=rudata_word(rpl,0);
                  a_tar :=integer(wt and %0000001111111111);
                  a_weap:=(wt and %1111110000000000) shr 10;
               end;

               if(uid^.uid_client_WCastTarget)then
                 if(buffs[ub_Cast]>0)then
                 begin
                    uo_x:=integer(rudata_byte(rpl,0) shl 5);
                    uo_y:=integer(rudata_byte(rpl,0) shl 5);
                 end;
            end;

            if(playeri=POVPlayer)
            or(g_gplayers[POVPlayer].isobserver)then rudata_OwnerUData(uu,rpl);
         end;
      end
      else
        case sh of
        -127: hits:=hits_dead;
        -128: hits:=hits_ndead;
        end;
      if(fast_skip)then
      begin
         vx:=x;
         vy:=y;
         vstp:=1;
      end;
   end;
   if(fast_skip)then
   begin
      ou^.x :=uu^.x;
      ou^.y :=uu^.y;
      ou^.vx:=uu^.x;
      ou^.vy:=uu^.y;
      unit_UpdateXY(ou);
   end
   else client_ChangeUnitState(uu,rpl);
end;


procedure rpdata_Upgrades(rpl:boolean;bs_alive:byte);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(GetBBit(@bs_alive,p))then
       begin
          bp:=0;

          for n:=0 to 255 do
            with g_upids[n] do
              if(race=upgr_race)then
              case bp of
              0: begin
                    bv:=rudata_byte(rpl,0);
                    upgrs_cur[n]:=min2i(upgr_max,bv and %00001111);
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
   with g_gplayers[p] do
   begin
     rudata_reload(@build_cd,rpl);
     res_HellPower:=rudata_int(rpl,0);
     res_UACLoot  :=rudata_int(rpl,0);
   end;
end;

procedure rclinet_KeyPoint(POVPlayer:byte;rpl,no_effect:boolean);
var
kpi,a,b:byte;
w      :word;
//active :boolean;
begin
   a     :=rudata_byte(rpl,0);
   kpi   :=a and %00001111;

   if(kpi<=LastKeyPoint)then
     with map_KeyPointsL[kpi] do
     with kp_TeamData[MaxPlayers] do
     begin
        kptd_Active:=(a and %00010000)>0;
        if(not kptd_Active)then exit;
        b:=rudata_byte(rpl,0);
        w:=word(a) or (b shl 8);
        kptd_lifeTime:=((w shr 5) and %0000011111111111)*fr_fps1;
        if(kptd_lifeTime>0)then kptd_lifeTime-=1;
        b:=rudata_byte(rpl,0);
        KeyPoint_ChangeOwner(kpi,b and %00001111,false);
        kptd_TimerOwnerPlayer:= b and %1111;

        //kp_TeamData[POVPlayer]:=kp_TeamData[MaxPlayers];
     end;
      {

      w:=(wdkpi^) and %0000000000001111;
      if(kptd_Active)then
      begin
         w:=w or %0000000000010000;
         w:=w or ((ct2s(kptd_lifeTime) and %11111111111) shl 5);

         kptd_OwnerPlayer
         kptd_TimerOwnerPlayer

         if(kptd_OwnerPlayer>=MaxPlayers)
         then b:=%00001111
         else b:=kptd_OwnerPlayer;

         if(kptd_TimerOwnerPlayer>=MaxPlayers)
         then o:=%1111
         else o:=(kptd_OwnerPlayer and %00001111) shl 4;


         kpdata_owner: begin
                          p:=b and kpdata_pmask;
                          if(p>LastPlayer)then p:=255;
                          KeyPoint_ChangeOwner(kpi,p);
                       end;
         kpdata_timer: begin
                          p:=b and kpdata_pmask;
                          if(p>LastPlayer)then p:=255;
                          kpTimerOwnerPlayer:=p;
                          rudata_reload(@kpTimer,rpl);
                       end;
         kpdata_life : begin
                          rudata_reload(@i,rpl);
                          kplifetime:=i*5;
                       end;
 }
end;

procedure rclinet_gframe(POVPlayer:byte;rpl,fast_skip:boolean);
var
wtick      : cardinal;
wtickb0,
wtickb1    : boolean;
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

   wtick:=g_tick shr 1;

   wtickb0:=(wtick mod fr_fpsh)=0;
   if(rpl)
   then wtickb1:=(wtick mod fr_fps1)=0  // every 2 second
   else wtickb1:= wtickb0;              // every second

   if(wtickb1)then
     case map_scenario of
mc_royale   : g_royal_r:=rudata_int(rpl,0);
     end;

   bs_defeated :=rudata_byte(rpl,0);
   bs_observer :=rudata_byte(rpl,0);
   bs_alive    :=0;
   units_ingame:=0;
   for i:=0 to LastPlayer do
     with g_gplayers[i] do
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
         UnitStepTicks:=round(units_ingame/rpls_pnu*NetTickN)+1;
         if(UnitStepTicks=0)then UnitStepTicks:=1;
      end;

      if(map_scenario=mc_KeyPoints)
      or(map_scenario=mc_KotH)
      or(map_generators>0)then
        rclinet_KeyPoint(POVPlayer,rpl,fast_skip);

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
           with g_gplayers[i] do
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
     with g_gplayers[LocalPlayer] do
     begin
        snd_SoundPlayUnitCommand(snd_rally_point[race]);
        rpoint_ChangeAnnoncer:=false;
     end;
end;
{$ENDIF}


