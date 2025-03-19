
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
       if(log_n<clog_n^)then
        if(log_n=0)
        then clog_n^:=0
        else clog_n^:=log_n-1;

       if(log_n>clog_n^)then
       begin
          s:=min3i(log_n,log_n-clog_n^,MaxPlayerLog);
          i:=log_i;
          clog_n^:=log_n;

          if(s>1)then
           for t:=1 to s-1 do
            if(i=0)
            then i:=MaxPlayerLog
            else i-=1;

          wudata_byte(byte(s),rpl);
          for t:=1 to s do
          begin
             with log_l[i] do
             begin
                wudata_byte  (mtype,rpl);
                b:=argt and %00000001;
                SetBBit(@b,2,argx       >0);
                SetBBit(@b,3,length(str)>0);
                SetBBit(@b,4,xi         >0);
                wudata_byte  (b,rpl);

                if(argx       >0)then wudata_byte  (argx ,rpl);
                if(length(str)>0)then wudata_string(str  ,rpl);
                if(xi         >0)then
                begin
                   wudata_byte(byte(xi shr 5),rpl);
                   wudata_byte(byte(yi shr 5),rpl);
                end;
             end;

             if(i=MaxPlayerLog)
             then i:=0
             else i+=1;
          end;
          if(rpl=false)then wudata_card(clog_n^,rpl);
          wudata_log:=true;
          exit;
       end;
    end;
   wudata_byte(0,rpl);
end;

////////////////////////////////////////////////////////////////////////////////

procedure wudata_StatusBytes(pu:PTUnit;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with pu^ do
   with uid^ do
   begin
      _bts1:=0;
      _bts2:=0;

      SetBBit(@_bts2,0, buff[ub_Resurect    ]>0);
      SetBBit(@_bts2,1, buff[ub_Summoned    ]>0);
      SetBBit(@_bts2,2, buff[ub_Invuln      ]>0);
      SetBBit(@_bts2,3, buff[ub_Teleport    ]>0);
      SetBBit(@_bts2,4, buff[ub_HVision     ]>0);
      SetBBit(@_bts2,5, buff[ub_Cast        ]>0);
      SetBBit(@_bts2,6, buff[ub_Scaned      ]>0);
      SetBBit(@_bts2,7, buff[ub_Decay       ]>0);

      SetBBit(@_bts1,0, iscomplete             );
      SetBBit(@_bts1,1, IsIntUnitRange(transport,nil));
      SetBBit(@_bts1,2, (level and %01)      >0);
      SetBBit(@_bts1,3, (level and %10)      >0);
      SetBBit(@_bts1,4, buff[ub_Pain        ]>0);
      SetBBit(@_bts1,5,(a_tar_cl>0)and(a_reload>0));
      ///SetBBit(@_bts1,6, isselected             );
      SetBBit(@_bts1,7, _bts2>0                );

      wudata_byte(_bts1,rpl);
      if(_bts2>0)then wudata_byte(_bts2,rpl);
   end;
end;

function wudata_reload(r:pinteger;rpl:boolean):byte;
begin
   if(r^<=0)
   then wudata_reload:=0
   else wudata_reload:=mm3i(1,(r^ div fr_fps1)+1,255);
   wudata_byte(wudata_reload,rpl);
end;

procedure wudata_production(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
   with uid^ do
   for i:=0 to MaxUnitLevel do
   begin
      if(i>level)then break;
      if(_isbarrack)then if(wudata_reload(@uprod_r[i],rpl)>0)then wudata_byte(uprod_u[i],rpl);
      if(_issmith  )then if(wudata_reload(@pprod_r[i],rpl)>0)then wudata_byte(pprod_u[i],rpl);
   end;
end;

procedure wudata_OwnerUData(pu:PTUnit;rpl:boolean);
var wudtick : pcardinal;
    wb      : boolean;
    b,
    ua_order: byte;
begin
   wb:=false;

   with pu^ do
   with uid^ do
   begin
      if(rpl)
      then wudtick:=@rpls_wudata_t[unum]
      else wudtick:= @net_wudata_t[unum];

      if(wudtick^>G_Step)
      then wb:=true
      else
        if((G_Step-wudtick^)>=fr_fpsd2)
        then wb:=true;

      ua_order:=unit_UA2UO(pu);

      if(wb)
      then b:=(group and %00001111) or ((ua_order and %00001111) shl 4)
      else b:=255;

      wudata_byte(b,rpl);

      if(b=255)then exit;

      wudtick^:=G_Step;

      if(iscomplete)then
       if(_ability in client_rld_abils)
       or(uidi     in client_rld_uids )then wudata_reload(@reload,rpl);

      if(_ukbuilding)then
      begin
         if(iscomplete)then wudata_production(pu,rpl);
         {if(isselected)and(UnitHaveRPoint(pu^.uidi))then
           if(IsIntUnitRange(ua_tar,nil))
           then wudata_int(-ua_tar,rpl)
           else
           begin
              wudata_int(ua_x,rpl);
              wudata_int(ua_y,rpl);
           end; }
      end;
   end;
end;

procedure wudata_main(pu:PTUnit;rpl:boolean;POVPlayer:byte);
var hits_si : shortint;
    wt      : word;
begin
   with pu^ do
   with uid^ do
   begin
      if(CheckUnitTeamVision(g_players[POVPlayer].team,pu,true))or(rpl)or(g_players[POVPlayer].isobserver)
      then hits_si:=hits_li2si(hits,_mhits,_shcf)
      else hits_si:=-128;

      wudata_sint(hits_si,rpl);
      if(hits_si>-127)then
      begin
         wudata_byte(uidi,rpl);
         wudata_StatusBytes(pu,rpl);

         if(IsIntUnitRange(transport,nil))
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
            if(a_tar_cl>0)and(a_reload>0)then
            begin
               wt:=0;
               if(IsIntUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
               wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
               wudata_word(wt,rpl);
            end;

            if(buff[ub_Cast]>0)then
             if(_ability in client_cast_abils)then
              if(wudata_reload(@reload,rpl)>0)then
              begin
                 wudata_byte(byte(ua_x shr 5),rpl);
                 wudata_byte(byte(ua_y shr 5),rpl);
              end;

            if(playeri=POVPlayer)or(g_players[POVPlayer].isobserver)then wudata_OwnerUData(pu,rpl);
         end;
      end;
   end;
end;

procedure wpdata_upgr(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
    if(GetBBit(@g_player_astatus,p))then
     with g_players[p] do
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
end; }

procedure wclinet_cpoint(cpi:byte;rpl:boolean);
var    b: byte;
wdcptime: pbyte;
begin
   b:=0;
   if(rpl)
   then wdcptime:=@rpls_cpoints_t[cpi]
   else wdcptime:= @net_cpoints_t[cpi];

   wdcptime^:=(wdcptime^+1) mod 2;

   with g_cpoints[cpi] do
    if(cpCaptureR<=0)
    then wudata_byte(0,rpl)
    else
    begin
       b:=b or (cpOwnerPlayer      shl 2) and %00011100;
       b:=b or (cpTimerOwnerPlayer shl 5) and %11100000;

       case wdcptime^ of
0       : begin
             wudata_byte(b or %00000010,rpl);
             if(cpOwnerPlayer<>cpTimerOwnerPlayer)
             then wudata_reload(@cpTimer,rpl);
          end;
1       : if(cpLifeTime<=0)
          then wudata_byte(b or %00000001,rpl)
          else
          begin
             wudata_byte(b or %00000011,rpl);
             wudata_byte((cpLifeTime div fr_fps1) shr 2,rpl);
          end;
       end;
    end;
end;

{function _dbg:cardinal;
begin
   _dbg:=G_Step-G_Step_dbg;
   G_Step_dbg:=G_Step;
end;}

procedure wclinet_gframe(POVPlayer:byte;rpl:boolean);
var
wstep  : cardinal;
wstepb0,
wstepb1: boolean;
 _N_U  : pinteger;
i,
 _PNU  : integer;
begin
   wudata_card(G_Step,rpl);

   wstep:=G_Step shr 1;

   wstepb0:=(wstep mod fr_fpsd2)=0;
   if(rpl)
   then wstepb1:=(wstep mod fr_fps1 )=0  // every 2 second
   else wstepb1:=wstepb0;                // every second

   if(rpl=false)and(wstepb1)then
    with g_players[POVPlayer] do wudata_reload(@build_cd,rpl);

   if(wstepb0)then
     if(g_mode=gm_capture)
     or(g_mode=gm_KotH)
     or(g_generators>1)then
      for i:=1 to MaxCPoints do
       wclinet_cpoint(i,rpl);

   if(wstepb1)then
     case g_mode of
gm_royale   : wudata_int (g_royal_r        ,rpl);
     end;

   if(rpl)then
   begin
      _PNU:=cl_UpT_array[rpls_Quality];
      _N_U:=@rpls_u;
   end
   else
   begin
      _PNU:= g_players[POVPlayer].PNU;
      _N_U:=@g_players[POVPlayer].n_u;
   end;

   if(not rpl)
   then UpdatePlayersStatusVars;

   //if(g_player_astatus>0)and(g_players[POVPlayer].isobserver)then SetBBit(@g_player_astatus,7,true);

   wudata_byte(g_player_astatus,rpl);
   if(g_player_astatus>0)then
   begin
      wudata_byte(_PNU,rpl);
      _PNU:=min2i(g_cl_units,_PNU*4);

      if(wstepb0)then
      begin
         wpdata_upgr(rpl);
         wudata_byte(g_player_rstatus,rpl);
      end;

      wudata_int(_N_U^,rpl);
      for i:=1 to _PNU do
      begin
         repeat
            _N_U^+=1;
            if (_N_U^<1)or(_N_U^>MaxUnits)then _N_U^:=1;
         until ( g_player_astatus and (1 shl ((_N_U^-1) div MaxPlayerUnits)) ) > 0 ;
         wudata_main(@g_units[_N_U^],rpl,POVPlayer);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

procedure unit_PC_client_inc(pu:PTUnit);
var i,_puid: byte;
          p: pinteger;
ptransport : PTUnit;
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

      ptransport:=nil;
      if(IsIntUnitRange(transport,@ptransport))then ptransport^.transportC+=_transportS;

      if(hits>0)and(ptransport=nil)then
      begin
         if(not iscomplete)
         then cenergy-=_renergy
         else
         begin
            unit_PC_complete_inc(pu);

            p:=@ucl_x[_ukbuilding,_ucl];
            if(p^=0)
            then p^:=unum
            else if(IsIntUnitRange(p^,nil))then
                   if(g_units[p^].uid^._ucl<>_ucl)then p^:=unum;

            p:=@uid_x[uidi];
            if(p^=0)
            then p^:=unum
            else if(IsIntUnitRange(p^,nil))then
                   if(g_units[p^].uidi<>uidi)then p^:=unum;

            if(_isbarrack)then
              for i:=0 to MaxUnitLevel do
                if(uprod_r[i]>0)then
                begin
                   _puid:=uprod_u[i];

                   uprodl+=g_uids[_puid]._limituse;
                   uproda+=1;
                   uprodc[g_uids[_puid]._ucl]+=1;
                   uprodu[       _puid      ]+=1;
                   cenergy-=g_uids[_puid]._renergy;
                end;
            if(_issmith)then
              for i:=0 to MaxUnitLevel do
                if(pprod_r[i]>0)then
                begin
                   _puid:=pprod_u[i] ;

                   upproda+=1;
                   upprodu[_puid]+=1;
                   pprod_e[i]:=upid_CalcCostEnergy(_puid,upgr[_puid]+1);
                   cenergy-=pprod_e[i];
                end;
         end;
      end;
   end;
end;

procedure unit_PC_client_dec(pu:PTUnit);
var i,_puid: byte;
ptransport : PTUnit;
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

      ptransport:=nil;
      if(IsIntUnitRange(transport,@ptransport))then ptransport^.transportC-=_transportS;

      if(hits>0)and(ptransport=nil)then
      begin
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

            unit_PC_done_dec(pu);

            if(_isbarrack)then
              for i:=0 to MaxUnitLevel do
                if(uprod_r[i]>0)then
                begin
                   _puid:=uprod_u[i];

                   uprodl-=g_uids[_puid]._limituse;
                   uproda-=1;
                   uprodc[g_uids[_puid]._ucl]-=1;
                   uprodu[       _puid      ]-=1;
                   cenergy+=g_uids[_puid]._renergy;
                end;
            if(_issmith)then
              for i:=0 to MaxUnitLevel do
                if(pprod_r[i]>0)then
                begin
                   _puid:=pprod_u[i];

                   upproda-=1;
                   upprodu[_puid]-=1;
                   cenergy+=pprod_e[i];
                end;
         end;
      end;
   end;
end;

procedure cleffect_UnitSummon(uu:PTUnit;vis:pboolean);
begin
   with uu^ do
   begin
      vx:=x;
      vy:=y;
      effect_UnitSummon(uu,vis);
   end;
end;

procedure cleffect_teleport(uu,pu:PTUnit);
begin
   with uu^  do
   begin
      vx:=x;
      vy:=y;
      if(uid^._ability=ua_HKeepBlink)then
      begin
         case uidi of
UID_HKeep   : effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_HKeep_H ,EID_HKeep_S ,snd_cube    );
         else effect_teleport(pu^.vx,pu^.vy,vx,vy,ukfly,EID_Teleport,EID_Teleport,snd_teleport);
         end;
         buff[ub_CCast]:=fr_fps1;
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

procedure client_ApplyNewUnitState(uu:PTUnit);
var pu,tu:PTUnit;
   vis:boolean;
begin
   // pu - previous state
   // uu - current state
   pu:=g_punits[0];
   with uu^ do
   with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // unit created
     begin
        unit_SetDefaults(uu,true);
        unit_BaseVision (uu,true);
        vx:=x;
        vy:=y;
        vis:=ui_CheckUnitUIPlayerVision(uu,true);

        if(IsIntUnitRange(transport,@tu))then
        begin
           unit_InTransportCode(uu,tu);
           vx:=x;
           vy:=y;
        end;

        unit_Bonuses(uu);

        if(hits>0)then
        begin
           unit_CalcFogR(uu);
           if(buff[ub_Summoned]>0)then cleffect_UnitSummon(uu,            @vis);
           if(buff[ub_Teleport]>0)then cleffect_teleport  (uu,            @vis);
           if(buff[ub_HVision ]>0)then   effect_LevelUp   (uu,EID_HVision,@vis);

           if(playeri=UIPlayer)then
           begin
              if(not iscomplete)then
                with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false,false);
           end;
        end;

        missiles_TargetClear(unum,true);
        unit_clear_a_tar(unum);

        unit_PC_client_inc(uu);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // unit removed
       begin
          unit_Bonuses(pu);

          vx:=x;
          vy:=y;
          vis:=ui_CheckUnitUIPlayerVision(uu,true);

          if(pu^.hits>0)and(vis)then
          begin
             if(hits>ndead_hits)and(not IsIntUnitRange(transport,nil))then
             begin
                if(buff[ub_Teleport]>0)then cleffect_teleport(uu,@vis);

                with uid^ do
                  if(_ukbuilding)and(_ability<>ua_HellVision)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                effect_UnitDeath(uu,true,@vis);
             end;
          end;

          if(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;

          missiles_TargetClear(unum,true);
          unit_clear_a_tar(unum);

          unit_PC_client_dec(pu);
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
               missiles_TargetClear(unum,true);
               unit_clear_a_tar(unum);
            end;
            vis:=ui_CheckUnitUIPlayerVision(uu,true);

            unit_Bonuses(pu);
            unit_PC_client_dec(pu);

            unit_Bonuses(uu);
            unit_PC_client_inc(uu);

            if(hits>0)then
            begin
               case(speed>0)of
               false: if(buff[ub_Teleport]>0)then if(pu^.x<>x)or(pu^.y<>y)then cleffect_teleport(uu,pu);
               true : if(pu^.buff[ub_Teleport]<=0)and(buff[ub_Teleport]>0)then cleffect_teleport(uu,pu);
               end;
               if(pu^.buff[ub_Summoned]<=0)and(buff[ub_Summoned]>0)then cleffect_UnitSummon(uu,            @vis);
               if(pu^.buff[ub_HVision ]<=0)and(buff[ub_HVision ]>0)then   effect_LevelUp   (uu,EID_HVision,@vis);
               if(pu^.buff[ub_Pain    ]<=0)and(buff[ub_Pain    ]>0)then   effect_UnitPain  (uu,            @vis);

               if(pu^.iscomplete)and(not iscomplete)then
                if(playeri=UIPlayer)then
                 with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false,false);

               //if(pu^.isselected=false)and(isselected)and(playeri=UIPlayer)then UpdateLastSelectedUnit(unum);
               if(pu^.transport<>transport)and(vis)then SoundPlayUnit(snd_transport,nil,@vis);

               if(iscomplete)then
               begin
                  if(pu^.buff[ub_Cast]<=0)and(buff[ub_Cast]>0)then
                   case uid^._ability of
               0:;
               ua_UStrike   : unit_ability_UACStrike_Shot(uu);
               ua_UScan     : if(ui_UIPlayerTeam(team))then SoundPlayUnit(snd_radar,nil,nil);
               ua_HSpawnLost   : if(upgr[upgr_hell_phantoms]>0)
                                 then ability_SpawnUnitStep(pu,UID_Phantom )
                                 else ability_SpawnUnitStep(pu,UID_LostSoul);
                   end;

                  if(uid^._ukbuilding=false)then
                  begin
                     if(pu^.level<level)then effect_LevelUp(uu,0,@vis);

                     if(pu^.buff[ub_Invuln]<=0)and(buff[ub_Invuln]>0)then effect_LevelUp(uu,EID_Invuln,@vis);
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
              if(pu^.hits>0)and(hits<=0)and(buff[ub_Resurect]=0)then  // death
              begin
                 with uid^ do
                   if(_ukbuilding)and(_ability<>ua_HellVision)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
                 effect_UnitDeath(uu,hits<=fdead_hits,@vis);

                 with uid^ do
                  if(_death_missile>0)
                  then missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);

                 if(playeri=UIPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
                 reload:=0;
              end;

            if(not IsIntUnitRange(pu^.transport,nil))then
             if(IsIntUnitRange(transport,@tu))then unit_InTransportCode(uu,tu);

            if(speed>0)then
            begin
               moveCurr_x:=pu^.x;
               moveCurr_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               unit_UpdateXY(uu,true);

               if(speed>0)then
               begin
                  vstp:=UnitMoveStepTicks;
                  dir :=point_dir(movePF_destY,movePF_destY,x,y);
               end
               else
               begin
                  missiles_TargetClear(unum,true);
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
   if(rpl)then
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
         rudata_string+=c;
      end;
   end
   else rudata_string:=net_readstring;
end;

function rudata_byte(rpl:boolean;def:byte):byte;
begin
   rudata_byte:=def;
   if(rpl)
   then begin {$I-}BlockRead(rpls_file,rudata_byte,SizeOf(rudata_byte));{$I+}if(ioresult<>0)then rudata_byte:=def;  end
   else rudata_byte:=net_readbyte;
end;

function rudata_word(rpl:boolean;def:word):word;
begin
   rudata_word:=def;
   if(rpl)
   then begin {$I-}BlockRead(rpls_file,rudata_word,SizeOf(rudata_word));{$I+}if(ioresult<>0)then rudata_word:=def;  end
   else rudata_word:=net_readword;
end;

function rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   rudata_sint:=def;
   if(rpl)
   then begin {$I-}BlockRead(rpls_file,rudata_sint,SizeOf(rudata_sint));{$I+}if(ioresult<>0)then rudata_sint:=def;  end
   else rudata_sint:=net_readsint;
end;

function rudata_int(rpl:boolean;def:integer):integer;
begin
   rudata_int :=def;
   if(rpl)
   then begin {$I-}BlockRead(rpls_file,rudata_int ,SizeOf(rudata_int ));{$I+}if(ioresult<>0)then rudata_int :=def;  end
   else rudata_int:=net_readint;
end;

function rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   rudata_card:=def;
   if(rpl)
   then begin {$I-}BlockRead(rpls_file,rudata_card,SizeOf(rudata_card));{$I+}if(ioresult<>0)then rudata_card:=def;  end
   else rudata_card:=net_readcard;
end;

procedure rudata_log(p:byte;rpl:boolean);
var s,b,
mtype,
argt,
argx,
x,y    : byte;
str    : shortstring;
begin
   s:=rudata_byte(rpl,0);
   if(s>0)then
   begin
      while(s>0)do
      begin
         mtype:=rudata_byte(rpl,0);
         b    :=rudata_byte(rpl,0);

         argt :=0;
         argx :=0;
         str  :='';
         x    :=255;
         y    :=255;

         argt:=b and %00000001;
         if(GetBBit(@b,2))then argx:=rudata_byte  (rpl,0);
         if(GetBBit(@b,3))then str :=rudata_string(rpl);
         if(GetBBit(@b,4))then
         begin
            x:=rudata_byte(rpl,0);
            y:=rudata_byte(rpl,0);
         end;

         if(x=255)
         then PlayerLogAdd(p,mtype,argt,argx,str,-1     ,-1     ,false)
         else PlayerLogAdd(p,mtype,argt,argx,str,x shl 5,y shl 5,false);

         s-=1;
      end;
      if(not rpl)then
      begin
         net_log_n:=rudata_card(rpl,net_log_n);
         menu_redraw:=true;
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure rudata_StatusBytes(uu:PTUnit;POVPlayer:byte;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with uu^ do
   begin
      a_weap:=255;
      level :=0;

      _bts1:=rudata_byte(rpl,0);

      iscomplete:=GetBBit(@_bts1,0);
      if(GetBBit(@_bts1,1))then transport:=1 else transport:=0;
      if(GetBBit(@_bts1,2))then level+=%01;
      if(GetBBit(@_bts1,3))then level+=%10;
      buff[ub_Pain]:=_buffst[GetBBit(@_bts1,4)];
      if(GetBBit(@_bts1,5))then a_tar:=-1 else a_tar:=0;
      //isselected:=GetBBit(@_bts1,6);
      if(GetBBit(@_bts1,7))
      then _bts2:=rudata_byte(rpl,0)
      else _bts2:=0;

      if(_bts2>0)then
      begin
         buff[ub_Resurect]:=_buffst[GetBBit(@_bts2,0)];
         if(GetBBit(@_bts2,1))and(buff[ub_Summoned]<=0)
         then buff[ub_Summoned]:=fr_fps1;
         buff[ub_Invuln  ]:=_buffst[GetBBit(@_bts2,2)];
         buff[ub_Teleport]:=_buffst[GetBBit(@_bts2,3)];
         buff[ub_HVision ]:=_buffst[GetBBit(@_bts2,4)];
         buff[ub_Cast    ]:=_buffst[GetBBit(@_bts2,5)];
         buff[ub_Scaned  ]:=_buffst[GetBBit(@_bts2,6)];
         buff[ub_Decay   ]:=_buffst[GetBBit(@_bts2,7)];
      end
      else
      begin
         buff[ub_Resurect]:=0;
         //buff[ub_Summoned]:=0;
         buff[ub_Invuln  ]:=0;
         buff[ub_Teleport]:=0;
         buff[ub_HVision ]:=0;
         buff[ub_Cast    ]:=0;
         buff[ub_Scaned  ]:=0;
         buff[ub_Decay   ]:=0;
      end;

      if(not rpl)and(not g_players[POVPlayer].isobserver)then
       with g_players[POVPlayer] do
        if(team>0)then
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

procedure rudata_production(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
   with uid^ do
   for i:=0 to MaxUnitLevel do
   begin
      if(i>level)then break;
      if(_isbarrack)then if(rudata_reload(@uprod_r[i],rpl)>0)then uprod_u[i]:=rudata_byte(rpl,0);
      if(_issmith  )then if(rudata_reload(@pprod_r[i],rpl)>0)then pprod_u[i]:=rudata_byte(rpl,0);
   end;
end;

procedure rudata_OwnerUData(uu:PTUnit;rpl:boolean);
var b : byte;
    tu: PTUnit;
begin
   with uu^  do
   with uid^ do
   begin
      b:=rudata_byte(rpl,0);

      if(b=255)then exit;

      group:= b and %00001111;
      b    :=(b and %11110000)shr 4;
      unit_ClientUO2UA(uu,b);

      if(iscomplete)then
       if(_ability in client_rld_abils)
       or(uidi     in client_rld_uids )then rudata_reload(@reload,rpl);

      if(_ukbuilding)then
      begin
         if(iscomplete)then rudata_production(uu,rpl);
         {if(isselected)and(UnitHaveRPoint(uidi))then
         begin
            ua_x:=rudata_int(rpl,0);
            if(IsIntUnitRange(-ua_x,@tu))then
            begin
               ua_tar:=-ua_x;
               ua_x  :=tu^.vx;
               ua_y  :=tu^.vy;
            end
            else
            begin
               ua_tar:=0;
               ua_y  :=rudata_int(rpl,0);
            end;
         end; }
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
            unit_apllyUID(uu);
            unit_SetDefaults(uu,false);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=hits_si2li(sh,uid^._mhits,uid^._shcf);
         rudata_StatusBytes(uu,POVPlayer,rpl);

         if(transport>0)then
         begin
            transport:=rudata_int(rpl,0);
            if(not IsIntUnitRange(transport,nil))then transport:=0;
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

            if(buff[ub_Cast]>0)then
             if(uid^._ability in client_cast_abils)then
              if(rudata_reload(@reload,rpl)>0)then
              begin
                 ua_x:=integer(rudata_byte(rpl,0) shl 5);
                 ua_y:=integer(rudata_byte(rpl,0) shl 5);
              end;

            if(playeri=POVPlayer)or(g_players[POVPlayer].isobserver)then rudata_OwnerUData(uu,rpl);
         end;
      end
      else hits:=hits_si2li(sh,uid^._mhits,uid^._shcf);
   end;
   if(SkipRead)then
   begin
      ou^.x :=uu^.x;
      ou^.y :=uu^.y;
      ou^.vx:=uu^.x;
      ou^.vy:=uu^.y;
      unit_UpdateXY(ou,true);
   end
   else client_ApplyNewUnitState(uu);
end;


procedure rpdata_upgr(rpl:boolean);
var p,n,bp,bv:byte;
begin
   for p:=0 to LastPlayer do
    if(GetBBit(@g_player_astatus,p))then
     with g_players[p] do
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

procedure rclient_cl_units;
var i:byte;
begin
   g_cl_units:=0;
   for i:=0 to LastPlayer do
    if(GetBBit(@g_player_astatus,i))then g_cl_units+=MaxPlayerUnits;
end;

procedure rclinet_cpoint(cpi:byte;rpl,no_effect:boolean);
var b,t,p:byte;
begin
   with g_cpoints[cpi] do
   begin
      b:=rudata_byte(rpl,0);
      t:=b and %00000011;
      if(t=0)then
      begin
         if(cpCaptureR>0)then
         begin
            CPoint_ChangeOwner(cpi,0);
            cpCaptureR:=-cpCaptureR;
            if(not no_effect)
            then effect_CPExplode(cpx,cpy);
         end;
      end
      else
      begin
         if(cpCaptureR<0)then cpCaptureR:=-cpCaptureR;
         p:=(b and %00011100) shr 2;
         CPoint_ChangeOwner(cpi,p);
         cpTimerOwnerPlayer:=(b and %11100000) shr 5;
         if(cpTimerOwnerPlayer<=LastPlayer)
         then cpTimerOwnerTeam:=g_players[cpTimerOwnerPlayer].team;

         case t of
%00000001 : ;
%00000010 : begin
               if(cpOwnerPlayer<>cpTimerOwnerPlayer)
               then rudata_reload(@cpTimer,rpl)
               else cpTimer:=0;
            end;
%00000011 : cpLifeTime:=(rudata_byte(rpl,0)*fr_fps1) shl 2;
         end;
      end;
   end;
end;

procedure rclinet_gframe(POVPlayer:byte;rpl,fast_skip:boolean);
var
wstep  : cardinal;
wstepb0,
wstepb1: boolean;
i,
_PNU,
_N_U   : integer;
begin
   G_Step:=rudata_card(rpl,G_Step);

   wstep:=G_Step shr 1;

   wstepb0:=(wstep mod fr_fpsd2)=0;
   if(rpl)
   then wstepb1:=(wstep mod fr_fps1)=0
   else wstepb1:=wstepb0;

   if(rpl=false)and(wstepb1)then
    with g_players[POVPlayer] do
     rudata_reload(@build_cd,rpl);

   if(wstepb0)then
     if(g_mode=gm_capture)
     or(g_mode=gm_KotH)
     or(g_generators>1)then
      for i:=1 to MaxCPoints do
       rclinet_cpoint(i,rpl,fast_skip);

   if(wstepb1)then
     case g_mode of
gm_royale   : g_royal_r        :=rudata_int (rpl,0);
     end;

   g_player_astatus:=rudata_byte(rpl,0);
   if(g_player_astatus>0)then
   begin
      //g_players[POVPlayer].isobserver:=GetBBit(@g_player_astatus,7);

      _PNU:=rudata_byte(rpl,0)*4;

      if(_PNU<=0)then exit;

      rclient_cl_units;

      if(_PNU>g_cl_units)then _PNU:=g_cl_units;

      if(_PNU<>rpls_pnu)then
      begin
         rpls_pnu:=_PNU;
         if(rpls_pnu<=0)then rpls_pnu:=1;
         UnitMoveStepTicks:=round(g_cl_units/rpls_pnu*NetTickN)+1;
         if(UnitMoveStepTicks=0)then UnitMoveStepTicks:=1;
      end;

      if(wstepb0)then
      begin
         rpdata_upgr(rpl);
         g_player_rstatus:=rudata_byte(rpl,0);
         for i:=0 to LastPlayer do
          with g_players[i] do
           isrevealed:=GetBBit(@g_player_rstatus,i);
      end;

      _N_U:=rudata_int(rpl,0);
      for i:=1 to _PNU do
      begin
         while(true)do
         begin
           _N_U+=1;
           if(_N_U<1)or(_N_U>MaxUnits)then _N_U:=1;
           g_units[_N_U].unum:=_N_U;
           if( g_player_astatus and (1 shl ((_N_U-1) div MaxPlayerUnits)) ) > 0
           then break
           else rudata_main(@g_units[_N_U],rpl,true,POVPlayer,fast_skip);
         end;
         rudata_main(@g_units[_N_U],rpl,false,POVPlayer,fast_skip);
      end;
   end;
end;
{$ENDIF}


