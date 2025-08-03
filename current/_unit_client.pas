
const

kpdata_owner  = %10000000;
kpdata_timer  = %11000000;
kpdata_life   = %01000000;
kpdata_pmask  = %00001111;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


procedure wudata_string(s:shortstring;rpl:boolean);
var sl,x:byte;
       c:char;
begin
   if(rpl=false)
   then net_writestring(s)
   else
   begin
      sl:=length(s);
      {$I-}
      BlockWrite(rpls_file,sl,SizeOf(sl));
      {$I+}
      for x:=1 to sl do
      begin
         c:=s[x];
         {$I-}
         BlockWrite(rpls_file,c,SizeOf(c));
         {$I+}
      end;
   end;
end;

procedure wudata_byte(bt:byte;rpl:boolean);
begin
   if(rpl=false)
   then net_writebyte(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure wudata_word(bt:word;rpl:boolean);
begin
   if(rpl=false)
   then net_writeword(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure wudata_sint(bt:shortint;rpl:boolean);
begin
   if(rpl=false)
   then net_writesint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure wudata_int(bt:integer;rpl:boolean);
begin
   if(rpl=false)
   then net_writeint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure wudata_card(bt:cardinal;rpl:boolean);
begin
   if(rpl=false)
   then net_writecard(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

function wudata_log(p:byte;clog_n:pcardinal;rpl:boolean):boolean;
var t,s:integer;
      i:cardinal;
      b:byte;
begin
   wudata_log:=false;
   if(p<=LastPlayer)then
     with g_players[p] do
     begin
        s:=0;

        i:=log_i;
        if(not rpl)then
        begin
           if(log_n<clog_n^)then
             if(log_n=0)
             then clog_n^:=0
             else clog_n^:=log_n-1;
           if(log_n>clog_n^)then
           begin
              s:=min3i(log_n,log_n-clog_n^,MaxPlayerLog);
              clog_n^:=log_n;
           end;
        end
        else
        begin
           s:=min2i(clog_n^,MaxPlayerLog);
           clog_n^:=0;
        end;

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
                 wudata_byte  (mtype,rpl);
                 b:=argt and %00000011;
                 if(argx       >0)then b:=b or %00000100;
                 if(length(str)>0)then b:=b or %00001000;
                 if(xi         >0)then b:=b or %00010000;
                 wudata_byte  (b,rpl);

                 if((b and %00000100)>0)then wudata_byte  (argx ,rpl);
                 if((b and %00001000)>0)then wudata_string(str  ,rpl);
                 if((b and %00010000)>0)then
                 begin
                    wudata_byte(byte(xi shr 5),rpl);
                    wudata_byte(byte(yi shr 5),rpl);
                 end;
              end;

              if(i=MaxPlayerLog)
              then i:=0
              else i+=1;
              s-=1;
           end;
           if(not rpl)then wudata_card(clog_n^,rpl);
           wudata_log:=true;
           exit;
        end;
     end;
   wudata_byte(0,rpl);
end;

////////////////////////////////////////////////////////////////////////////////

procedure wudata_bstat(pu:PTUnit;rpl:boolean);
var byte1,
    byte2:byte;
begin
   with pu^ do
   with uid^ do
   begin
      byte1:=0;
      byte2:=0;

      SetBBit(@byte2,0, buffs[ub_Resurect    ]>0);
      SetBBit(@byte2,1, buffs[ub_Summoned    ]>0);
      SetBBit(@byte2,2, buffs[ub_Invuln      ]>0);
      SetBBit(@byte2,3, buffs[ub_Teleport    ]>0);
      SetBBit(@byte2,4, buffs[ub_HVision     ]>0);
      SetBBit(@byte2,5, buffs[ub_Cast        ]>0);
      SetBBit(@byte2,6, buffs[ub_Scaned      ]>0);

      SetBBit(@byte1,0, iscomplete             );
      SetBBit(@byte1,1, transport>0            );
      SetBBit(@byte1,2, (level and %01)      >0);
      SetBBit(@byte1,3, (level and %10)      >0);
      SetBBit(@byte1,4, buffs[ub_Pain        ]>0);
      SetBBit(@byte1,5,(a_tar_cl>0)and(a_rld>0));
      SetBBit(@byte1,6, isselected                    );
      SetBBit(@byte1,7, byte2>0                );

      wudata_byte(byte1,rpl);
      if(byte2>0)then wudata_byte(byte2,rpl);
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
     if(_ukbuilding)and(iscomplete)then
       for i:=0 to MaxUnitLevel do
       begin
          if(i>level)then break;
          if(_isbarrack)then if(wudata_reload(uprod_r[i],rpl)>0)then wudata_byte(uprod_u[i],rpl);
          if(_issmith  )then if(wudata_reload(pprod_r[i],rpl)>0)then wudata_byte(pprod_u[i],rpl);
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
      if(rpl)
      then wudtick:=@rpls_wudata_t[unum]
      else wudtick:=@net_wudata_t[unum];
      if(rpl)
      then wudelay:=fr_fpsh
      else wudelay:=fr_fpsq;

      if(wudtick^>g_tick)
      then wb:=true
      else
        if((g_tick-wudtick^)>=wudelay)
        then wb:=true;

      if(rpl)
      then b:=group and %00001111
      else b:=0;
      uo:=uo_id;
      if(uo_bx>0)then uo:=ua_patrol;

      b:=b or ((uo and %00000111) shl 4);

      if(wb)then b:=b or %10000000;

      wudata_byte(b,rpl);

      if(not wb)then exit;

      wudtick^:=g_tick;

      if(iscomplete)then
        if(_ability in client_rld_abils)
        or(uidi     in client_rld_uids )then wudata_reload(rld,rpl);

      wudata_prod(pu,rpl);

      if(isselected or not rpl)then
        if(UnitHaveRPoint(pu^.uidi))or(uo=ua_psability)then
          if(IsUnitRange(uo_tar,nil))
          then wudata_int(-uo_tar,rpl)
          else
          begin
             wudata_int(uo_x,rpl);
             wudata_int(uo_y,rpl);
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
      if(CheckUnitTeamVision(g_players[POVPlayer].team,pu,true))or(rpl)or(g_players[POVPlayer].observer)
      then hits_si:=hits_li2si(hits,_mhits,_shcf)
      else hits_si:=-128;

      wudata_sint(hits_si,rpl);
      if(hits_si>-127)then
      begin
         wudata_byte (uidi,rpl);
         wudata_bstat(pu,rpl);

         if(transport>0)
         then wudata_int(transport,rpl)
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
            if(a_tar_cl>0)and(a_rld>0)then
            begin
               wt:=0;
               if(IsUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
               wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
               wudata_word(wt,rpl);
            end;

            if(buffs[ub_Cast]>0)then
             if(_ability in client_cast_abils)then
              if(wudata_reload(rld,rpl)>0)then
              begin
                 wudata_byte(byte(uo_x shr 5),rpl);
                 wudata_byte(byte(uo_y shr 5),rpl);
              end;

            if(playeri=POVPlayer)or(g_players[POVPlayer].observer)then wudata_OwnerUData(pu,rpl);
         end;
      end;
   end;
end;

procedure wpdata_Upgrades(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_players[p] do
       if(not observer)and(not defeated)then
       begin
          bp:=0;

          for n:=0 to 255 do
            if(race=g_upids[n]._up_race)then
              case bp of
                0: begin
                      bv:=upgr[n];
                      bp:=1;
                   end;
                1: begin
                      bv:=bv or (upgr[n] shl 4);
                      wudata_byte(bv,rpl);
                      bp:=0;
                      bv:=0;
                   end;
                end;

            if(bp=1)then wudata_byte(bv,rpl);
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

procedure wclinet_KeyPoint(kpi:byte;rpl:boolean);
var  o,b: byte;
wdcptime: pbyte;
procedure WriteOwner;
begin
   with g_KeyPoints[kpi] do
   begin
      b:=kpdata_owner;
      if(kpOwnerPlayer>MaxPlayers)
      then o:=kpdata_pmask
      else o:=kpOwnerPlayer;
      o:=o and kpdata_pmask;

      wudata_byte(b or o,rpl);
   end;
end;
procedure WriteTimer;
begin
   with g_KeyPoints[kpi] do
   begin
      b:=kpdata_timer;
      if(kpTimerOwnerPlayer>MaxPlayers)
      then o:=kpdata_pmask
      else o:=kpTimerOwnerPlayer;
      o:=o and kpdata_pmask;

      wudata_byte(b or o,rpl);
      wudata_reload(kpTimer,rpl);
   end;
end;
procedure WriteLife;
begin
   with g_KeyPoints[kpi] do
   begin
     b:=kpdata_life;

     wudata_byte(b,rpl);
     wudata_reload(integer(kplifetime div 5),rpl);
     writeln(kpi,' ',integer(kplifetime div 5));
   end;
end;

begin
   b:=0;
   if(rpl)
   then wdcptime:=@rpls_kpoints_t[kpi]
   else wdcptime:= @net_kpoints_t[kpi];

   wdcptime^:=(wdcptime^+1) mod 3;

   with g_KeyPoints[kpi] do
     if(kpCaptureR<=0)
     then wudata_byte(0,rpl)
     else
       case wdcptime^ of
       0 : WriteOwner;
       1 : WriteTimer;
       2 : if(map_generators=mapg_inf)or((map_scenario=mc_KotH)and(kpi=0))then
           begin
              if(kpTimer>0)
              then WriteTimer
              else WriteOwner;
           end
           else WriteLife;
       end;
end;

procedure wclinet_gframe(POVPlayer:byte;rpl:boolean);
var
wtick      : cardinal;
wtickb0,
wtickb1    : boolean;
lastPUnit  : pinteger;
bs_alive,
bs_observer,
bs_defeated,
bs_revealed : byte;
i,
units_ingame,
units_now   : integer;
begin
   wudata_card(g_tick,rpl);

   wtick:=g_tick shr 1;

   wtickb0:=(wtick mod fr_fpsh)=0;
   if(rpl)
   then wtickb1:=(wtick mod fr_fps1 )=0  // every 2 second
   else wtickb1:=wtickb0;                // every second

   if(not rpl)and(wtickb1)then
     with g_players[POVPlayer] do wudata_reload(build_cd,rpl);

   if(wtickb0)then
     if(map_scenario=mc_capture)
     or(map_scenario=mc_KotH)
     or(map_generators>0)then
       for i:=0 to LastKeyPoint do
         wclinet_KeyPoint(i,rpl);

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
      units_now:= g_players[POVPlayer].PNU;
      lastPUnit:=@g_players[POVPlayer].n_u;
   end;

   bs_alive:=0;
   bs_observer:=0;
   bs_defeated:=0;
   bs_revealed:=0;
   units_ingame:=0;
   for i:=0 to LastPlayer do
     with g_players[i] do
       if(state>ps_None)then
       begin
          if(observer)then SetBBit(@bs_observer,i,true);
          if(defeated)then SetBBit(@bs_defeated,i,true);
          if(revealed)then SetBBit(@bs_revealed,i,true);
          if(not defeated)and(not observer)then
          begin
             SetBBit(@bs_alive,i,true);
             units_ingame+=MaxPlayerUnits;
          end;
       end;

   wudata_byte(bs_observer,rpl);
   wudata_byte(bs_defeated,rpl);

   if(bs_alive>0)then
   begin
      if(units_now>255)then units_now:=255;
      wudata_byte(byte(units_now),rpl);

      if(units_now=0)then exit;

      units_now:=min2i(units_ingame,units_now*4);

      if(wtickb0)then
      begin
         wpdata_Upgrades(rpl);
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

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

procedure client_UnitCountersInc(pu:PTUnit;rpl:boolean);
var i,_puid:byte;
    p:pinteger;
ptransport:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      ucl_l[_ukbuilding     ]+=_limituse;
      uid_e[uidi            ]+=1;
      if(_isbuilder)then e_builders+=1;

      ptransport:=nil;
      if(IsUnitRange(transport,@ptransport))then ptransport^.transportC+=_transportS;

      if(hits>0)and(ptransport=nil)then
      begin
         if(isselected)and(rpl)then unit_counters_inc_select(pu);
         if(not iscomplete)
         then cenergy-=_renergy
         else
         begin
            unit_bld_inc_cntrs(pu);

            p:=@ucl_x[_ukbuilding,_ucl];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(g_units[p^].uid^._ucl<>_ucl)then p^:=unum;

            p:=@uid_x[uidi];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(g_units[p^].uidi<>uidi)then p^:=unum;

            if(_isbarrack)then
             for i:=0 to MaxUnitLevel do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uprodl+=g_uids[_puid]._limituse;
                 uproda+=1;
                 uprodc[g_uids[_puid]._ucl]+=1;
                 uprodu[      _puid      ]+=1;
                 cenergy-=g_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitLevel do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i] ;

                 upproda+=1;
                 upprodu[_puid]+=1;
                 pprod_e[i]:=GetUpgradeEnergy(_puid,upgr[_puid]+1);
                 cenergy-=pprod_e[i];
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
      army-=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      ucl_l[_ukbuilding     ]-=_limituse;
      uid_e[uidi            ]-=1;
      if(_isbuilder)then e_builders-=1;

      ptransport:=nil;
      if(IsUnitRange(transport,@ptransport))then ptransport^.transportC-=_transportS;

      if(hits>0)and(ptransport=nil)then
      begin
         if(isselected)and(rpl)then unit_counters_dec_select(pu);
         if(not iscomplete)
         then cenergy+=_renergy
         else
         begin
            cenergy-=_genergy;
            menergy-=_genergy;
            uid_eb[uidi]-=1;
            ucl_eb[_ukbuilding,_ucl]-=1;
            if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
            if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;

            unit_done_dec_cntrs(pu);

            if(_isbarrack)then
             for i:=0 to MaxUnitLevel do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uprodl-=g_uids[_puid]._limituse;
                 uproda-=1;
                 uprodc[g_uids[_puid]._ucl]-=1;
                 uprodu[      _puid      ]-=1;
                 cenergy+=g_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitLevel do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i];

                 upproda-=1;
                 upprodu[_puid]-=1;
                 //pprod_e[i]:=GetUpgradeEnergy(_puid,upgr[_puid]+1);
                 cenergy+=pprod_e[i];
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
      if(uid^._ability=uab_HKeepBlink)then
      begin
         case uidi of
UID_HKeep   : effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_HKeep_H ,EID_HKeep_S ,snd_cube    );
UID_HAKeep  : effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_HAKeep_H,EID_HAKeep_S,snd_cube    );
         else effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_Teleport,EID_Teleport,snd_teleport);
         end;
         buffs[ub_CCast]:=fr_fps1;
         exit;
      end // default teleport effects
      else effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_Teleport,EID_Teleport,snd_teleport)
   end;
end;

procedure unit_clear_a_tar(tar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(a_tar=tar)then a_tar:=0;
end;

procedure client_ChangeUnitState(uu:PTUnit;rpl:boolean);
var pu,tu:PTUnit;
   vis:boolean;
begin
   // pu - previous state
   // uu - current state
   pu:=@g_units[0];

   if(not rpl)then
     if(pu^.uidi<>uu^.uidi)then
     begin
        unit_UnSelect(pu);
        uu^.group:=0;
        uu^.isselected:=false;
     end
     else
       if(uu^.hits<=0)
       or(uu^.transport>0)then
       begin
          unit_UnSelect(uu);
          uu^.group:=0;
       end;

   with uu^ do
   with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // create unit
     begin
        unit_SetDefaults(uu,true);
        unit_reveal     (uu,true);
        vx:=x;
        vy:=y;
        vis:=ui_CheckUnitUIPlayerVision(uu,true);

        if(IsUnitRange(transport,@tu))then
        begin
           unit_InTransportCode(uu,tu);
           vx:=x;
           vy:=y;
        end;

        unit_Bonuses(uu);

        if(hits>0)then
        begin
           unit_CalcFogR(uu);
           if(buffs[ub_Summoned]>0)then cleffect_UnitSummon(uu,            @vis);
           if(buffs[ub_Teleport]>0)then cleffect_teleport  (uu,            @vis);
           if(buffs[ub_HVision ]>0)then   effect_LevelUp   (uu,EID_HVision,@vis);

           if(playeri=UIPlayer)then
           begin
              if(not iscomplete)then
                with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false,false);
              if(not rpl)and(isselected)then ui_UpdateLastSelectedUnit(unum);
           end;
        end;

        missiles_clear_tar(unum,true);
        unit_clear_a_tar(unum);

        client_UnitCountersInc(uu,rpl);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // remove unit
       begin
          unit_Bonuses(pu);

          vx:=x;
          vy:=y;
          vis:=ui_CheckUnitUIPlayerVision(uu,true);

          if(pu^.hits>0)and(vis)then
          begin
             if(hits>ndead_hits)and(transport=0)then
             begin
                if(buffs[ub_Teleport]>0)then cleffect_teleport(uu,@vis);

                with uid^ do
                  if(_ukbuilding)and(_ability<>uab_HellVision)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                effect_UnitDeath(uu,true,@vis);
             end;
          end;

          if(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;

          missiles_clear_tar(unum,true);
          unit_clear_a_tar(unum);

          client_UnitCountersDec(pu,rpl);
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
               missiles_clear_tar(unum,true);
               unit_clear_a_tar(unum);
            end;
            vis:=ui_CheckUnitUIPlayerVision(uu,true);

            unit_Bonuses(pu);
            client_UnitCountersDec(pu,rpl);

            unit_Bonuses(uu);
            client_UnitCountersInc(uu,rpl);

            if(hits>0)then
            begin
               case(speed>0)of
               false: if(buffs[ub_Teleport]>0)then if(pu^.x<>x)or(pu^.y<>y)then cleffect_teleport(uu,pu);
               true : if(pu^.buffs[ub_Teleport]<=0)and(buffs[ub_Teleport]>0)then cleffect_teleport(uu,pu);
               end;
               if(pu^.buffs[ub_Summoned]<=0)and(buffs[ub_Summoned]>0)then cleffect_UnitSummon(uu,            @vis);
               if(pu^.buffs[ub_HVision ]<=0)and(buffs[ub_HVision ]>0)then   effect_LevelUp   (uu,EID_HVision,@vis);
               if(pu^.buffs[ub_Pain    ]<=0)and(buffs[ub_Pain    ]>0)then   effect_UnitPain  (uu,            @vis);

               if(pu^.iscomplete)and(not iscomplete)then
                 if(playeri=UIPlayer)then
                   with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false,false);

               if(not rpl)and(pu^.isselected=false)and(isselected)and(playeri=UIPlayer)then ui_UpdateLastSelectedUnit(unum);
               if(pu^.transport<>transport)and(vis)then SoundPlayUnit(snd_transport,nil,@vis);

               if(iscomplete)then
               begin
                  if(pu^.buffs[ub_Cast]<=0)and(buffs[ub_Cast]>0)then
                   case uid^._ability of
                   0:;
                   uab_UACStrike   : unit_UACStrike_missile(uu);
                   uab_UACScan     : if(UIPlayer>LastPlayer)
                                     then SoundPlayUnit(snd_radar,nil,nil)
                                     else
                                       if(team=g_players[UIPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
                   uab_SpawnLost   : if(upgr[upgr_hell_phantoms]>0)
                                     then ability_unit_spawn(pu,UID_Phantom )
                                     else ability_unit_spawn(pu,UID_LostSoul);
                   end;

                  if(uid^._ukbuilding=false)then
                  begin
                     if(pu^.level<level)then effect_LevelUp(uu,0,@vis);

                     if(pu^.buffs[ub_Invuln]<=0)and(buffs[ub_Invuln]>0)then effect_LevelUp(uu,EID_Invuln,@vis);
                  end;
               end;
            end;

            if(pu^.hits<=0)and(hits>0)then  //resurrected
            begin
               unit_CalcFogR(uu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buffs[ub_Resurect]=0)then  // death
              begin
                 with uid^ do
                   if(_ukbuilding)and(_ability<>uab_HellVision)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                 effect_UnitDeath(uu,hits<=fdead_hits,@vis);

                 with uid^ do
                   if(_death_missile>0)
                   then missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);

                 if(not rpl)and(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
                 rld:=0;
              end;

            if(not IsUnitRange(pu^.transport,nil))then
             if(IsUnitRange(transport,@tu))then unit_InTransportCode(uu,tu);

            if(speed>0)then
            begin
               mv_x:=pu^.x;
               mv_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               unit_UpdateXY(uu);

               if(speed>0)then
               begin
                  vstp:=UnitStepTicks;
                  dir :=point_dir(mp_x,mp_y,x,y);
               end;
               if(speed<=0)or(buffs[ub_Teleport]>0)then
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

function rudata_string(rpl:boolean):shortstring;
var sl,x:byte;
       c:char;
begin
   if(not rpl)
   then rudata_string:=net_readstring
   else
   begin
      sl:=0;
      rudata_string:='';
      {$I-}
      BlockRead(rpls_file,sl,SizeOf(sl));
      {$I+}
      for x:=1 to sl do
      begin
         c:=#0;
         {$I-}
         BlockRead(rpls_file,c,SizeOf(c));
         {$I+}
         rudata_string:=rudata_string+c;
      end;
   end;
end;

function rudata_byte(rpl:boolean;def:byte):byte;
begin
   if(not rpl)
   then rudata_byte:=net_readbyte
   else begin {$I-} BlockRead(rpls_file,rudata_byte,SizeOf(rudata_byte));{$I+}if(ioresult<>0)then rudata_byte:=def;  end;
end;

function rudata_word(rpl:boolean;def:word):word;
begin
   if(not rpl)
   then rudata_word:=net_readword
   else begin {$I-} BlockRead(rpls_file,rudata_word,SizeOf(rudata_word));{$I+}if(ioresult<>0)then rudata_word:=def;  end;
end;

function rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   if(not rpl)
   then rudata_sint:=net_readsint
   else begin {$I-} BlockRead(rpls_file,rudata_sint,SizeOf(rudata_sint));{$I+}if(ioresult<>0)then rudata_sint:=def;  end;
end;

function rudata_int(rpl:boolean;def:integer):integer;
begin
   if(not rpl)
   then rudata_int:=net_readint
   else begin {$I-} BlockRead(rpls_file,rudata_int ,SizeOf(rudata_int ));{$I+}if(ioresult<>0)then rudata_int :=def;  end;
end;

function rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   if(not rpl)
   then rudata_card:=net_readcard
   else begin {$I-} BlockRead(rpls_file,rudata_card,SizeOf(rudata_card));{$I+}if(ioresult<>0)then rudata_card:=def;  end;
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
var s,b,
mtype,
argt,
argx,
x,y    :byte;
    str:shortstring;
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
         net_log_n:=rudata_card(rpl,net_log_n);
         menu_update:=true;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure rudata_bstat(uu:PTUnit;POVPlayer:byte;rpl:boolean);
var byte1,
    byte2:byte;
begin
   with uu^ do
   begin
      a_weap:=255;
      level:=0;

      byte1:=rudata_byte(rpl,0);

      iscomplete:=GetBBit(@byte1,0);
      if(GetBBit(@byte1,1))then transport:=1 else transport:=0;
      if(GetBBit(@byte1,2))then level+=%01;
      if(GetBBit(@byte1,3))then level+=%10;
      buffs[ub_Pain]:=_buffst[GetBBit(@byte1,4)];
      if(GetBBit(@byte1,5))then a_tar:=-1 else a_tar:=0;
      if(rpl)then
        isselected:=GetBBit(@byte1,6);
      if(GetBBit(@byte1,7))
      then byte2:=rudata_byte(rpl,0)
      else byte2:=0;

      if(byte2>0)then
      begin
         buffs[ub_Resurect]:=_buffst[GetBBit(@byte2,0)];
         if(GetBBit(@byte2,1))and(buffs[ub_Summoned]<=0)
         then buffs[ub_Summoned]:=fr_fps1;
         buffs[ub_Invuln  ]:=_buffst[GetBBit(@byte2,2)];
         buffs[ub_Teleport]:=_buffst[GetBBit(@byte2,3)];
         buffs[ub_HVision ]:=_buffst[GetBBit(@byte2,4)];
         buffs[ub_Cast    ]:=_buffst[GetBBit(@byte2,5)];
         buffs[ub_Scaned  ]:=_buffst[GetBBit(@byte2,6)];
      end
      else
      begin
         buffs[ub_Resurect]:=0;
         buffs[ub_Invuln  ]:=0;
         buffs[ub_Teleport]:=0;
         buffs[ub_HVision ]:=0;
         buffs[ub_Cast    ]:=0;
         buffs[ub_Scaned  ]:=0;
      end;

      if(not rpl)and(not g_players[POVPlayer].observer)then
        with g_players[POVPlayer] do
          AddToInt(@TeamVision[team],MinVisionTime);
   end;
end;

function rudata_reload(r:pinteger;rpl:boolean):byte;
begin
   rudata_reload  :=rudata_byte(rpl,0);
   if(rudata_reload=0)
   then r^:=0
   else r^:=rudata_reload*fr_fps1-1;
end;

procedure rudata_prod(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
   with uid^ do
     if(_ukbuilding)and(iscomplete)then
       for i:=0 to MaxUnitLevel do
         if(i<=level)then
         begin
            if(_isbarrack)then if(rudata_reload(@uprod_r[i],rpl)>0)then uprod_u[i]:=rudata_byte(rpl,0);
            if(_issmith  )then if(rudata_reload(@pprod_r[i],rpl)>0)then pprod_u[i]:=rudata_byte(rpl,0);
         end
         else
         begin
            uprod_r[i]:=0;
            uprod_u[i]:=0;
            pprod_r[i]:=0;
            pprod_u[i]:=0;
         end;
end;

procedure rudata_OwnerUData(uu:PTUnit;rpl:boolean);
var puo,
    b : byte;
    tu: PTUnit;
begin
   with uu^  do
   with uid^ do
   begin
      b:=rudata_byte(rpl,0);

      if(rpl)then group:=b and %00001111;

      puo:=uo_id;
      uo_id:=(b and %01110000)shr 4;
      if(uo_id=ua_patrol)then
      begin
         uo_bx:=1;
         uo_id:=ua_amove;
      end
      else uo_bx:=-1;

      if(puo<>ua_psability)and(uo_id=ua_psability)then uo_x:=-1;

      if((b and %10000000)=0)then exit;

      if(iscomplete)then
        if(_ability in client_rld_abils)
        or(uidi     in client_rld_uids )then rudata_reload(@rld,rpl);

      rudata_prod(uu,rpl);

      if(isselected or not rpl)then
        if(UnitHaveRPoint(uidi))or(uo_id=ua_psability)then
        begin
           uo_x:=rudata_int(rpl,0);
           if(IsUnitRange(-uo_x,@tu))then
           begin
              uo_tar:=-uo_x;
              uo_x  :=tu^.vx;
              uo_y  :=tu^.vy;
           end
           else
           begin
              uo_tar:=0;
              uo_y  :=rudata_int(rpl,0);
           end;
        end;
   end;
end;

procedure rudata_main(uu:PTUnit;rpl,DEAD:boolean;POVPlayer:byte;SkipRead:boolean);
var sh: shortint;
    i : byte;
    wt: word;
    ou: PTUnit;
begin
   if(SkipRead)then
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
      player :=@g_players[playeri];
      if(not DEAD)
      then sh:=rudata_sint(rpl,-128)
      else
        if(hits<dead_hits)
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
         hits:=hits_si2li(sh,uid^._mhits,uid^._shcf);
         rudata_bstat(uu,POVPlayer,rpl);

         if(transport>0)then
         begin
            transport:=rudata_int(rpl,0);
            if(IsUnitRange(transport,nil)=false)then transport:=0;
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
            if(a_tar=-1)then
            begin
               wt    :=rudata_word(rpl,0);
               a_tar :=integer(wt and %0000001111111111);
               a_weap:=(wt and %1111110000000000) shr 10;
            end;

            if(buffs[ub_Cast]>0)then
             if(uid^._ability in client_cast_abils)then
              if(rudata_reload(@rld,rpl)>0)then
              begin
                 uo_x:=integer(rudata_byte(rpl,0) shl 5);
                 uo_y:=integer(rudata_byte(rpl,0) shl 5);
              end;

            if(playeri=POVPlayer)or(g_players[POVPlayer].observer)then rudata_OwnerUData(uu,rpl);
         end;
      end
      else
        case sh of
        -127: hits:=dead_hits;
        -128: hits:=ndead_hits;
        end;
   end;
   if(SkipRead)then
   begin
      ou^.x :=uu^.x;
      ou^.y :=uu^.y;
      ou^.vx:=uu^.x;
      ou^.vy:=uu^.y;
      unit_UpdateXY(ou);
   end
   else client_ChangeUnitState(uu,rpl);
end;


procedure rpdata_Upgrades(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
     with g_players[p] do
       if(not observer)and(not defeated)then
       begin
          bp:=0;

          for n:=0 to 255 do
            with g_upids[n] do
              if(race=_up_race)then
              case bp of
              0: begin
                    bv:=rudata_byte(rpl,0);
                    upgr[n]:=min2i(_up_max,bv and %00001111);
                    bp:=1;
                 end;
              1: begin
                    upgr[n]:=min2i(_up_max,bv shr 4);
                    bp:=0;
                 end;
              end;
       end;
end;

procedure rclinet_KeyPoint(kpi:byte;rpl,no_effect:boolean);
var
b,t,p:byte;
i    :integer;
begin
   with g_KeyPoints[kpi] do
   begin
      b:=rudata_byte(rpl,0);
      t:=b and %11000000;
      case t of
      0 : if(kpCaptureR>0)then
          begin
             KeyPoint_ChangeOwner(kpi,255);
             kpCaptureR:=-kpCaptureR;
             if(not no_effect)then
               effect_KPointExplode(kpx,kpy);
          end;
      else

        if(kpCaptureR<0)then kpCaptureR:=-kpCaptureR;
        if(map_generators=mapg_inf)
        or((map_scenario=mc_koth)and(kpi=0))then kplifetime:=0;

        case t of
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
                         writeln(kpi,' ',i);
                         kplifetime:=i*5;
                      end;
        end;
      end;
   end;
end;

procedure rclinet_gframe(POVPlayer:byte;rpl,fast_skip:boolean);
var
wtick  : cardinal;
wtickb0,
wtickb1: boolean;
bs_alive,
bs     : byte;
i,
units_ingame,
units_now,
lastUnit   : integer;
begin
   g_tick:=rudata_card(rpl,g_tick);

   wtick:=g_tick shr 1;

   wtickb0:=(wtick mod fr_fpsh)=0;
   if(rpl)
   then wtickb1:=(wtick mod fr_fps1)=0
   else wtickb1:=wtickb0;

   if(not rpl)and(wtickb1)then
     with g_players[POVPlayer] do
       rudata_reload(@build_cd,rpl);

   if(wtickb0)then
     if(map_scenario=mc_capture)
     or(map_scenario=mc_KotH)
     or(map_generators>0)then
       for i:=0 to LastKeyPoint do
         rclinet_KeyPoint(i,rpl,fast_skip);

   if(wtickb1)then
     case map_scenario of
mc_royale   : g_royal_r:=rudata_int(rpl,0);
     end;

   bs:=rudata_byte(rpl,0);
   for i:=0 to LastPlayer do
     with g_players[i] do
       if(state>ps_None)then
         observer:=GetBBit(@bs,i);
   bs:=rudata_byte(rpl,0);
   for i:=0 to LastPlayer do
     with g_players[i] do
       if(state>ps_None)then
         defeated:=GetBBit(@bs,i);
   bs_alive:=0;
   units_ingame:=0;
   for i:=0 to LastPlayer do
     with g_players[i] do
       if(state>ps_None)and(not observer)and(not defeated)then
       begin
          SetBBit(@bs_alive,i,true);
          units_ingame+=MaxPlayerUnits;
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

      if(wtickb0)then
      begin
         rpdata_Upgrades(rpl);
         bs:=rudata_byte(rpl,0);
         for i:=0 to LastPlayer do
           with g_players[i] do
             revealed:=GetBBit(@bs,i);
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
           else rudata_main(@g_units[lastUnit],rpl,true,POVPlayer,fast_skip);
         end;
         rudata_main(@g_units[lastUnit],rpl,false,POVPlayer,fast_skip);
      end;
   end;
end;
{$ENDIF}


