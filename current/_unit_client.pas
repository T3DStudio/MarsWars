
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


procedure _wudata_string(s:shortstring;rpl:boolean);
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
      for x:=1 to sl do
      begin
         c:=s[x];
         BlockWrite(rpls_file,c,SizeOf(c));
      end;
      {$I+}
   end;
end;

procedure _wudata_byte(bt:byte;rpl:boolean);
begin
   if(rpl=false)
   then net_writebyte(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_word(bt:word;rpl:boolean);
begin
   if(rpl=false)
   then net_writeword(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_sint(bt:shortint;rpl:boolean);
begin
   if(rpl=false)
   then net_writesint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_int(bt:integer;rpl:boolean);
begin
   if(rpl=false)
   then net_writeint(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_card(bt:cardinal;rpl:boolean);
begin
   if(rpl=false)
   then net_writecard(bt)
   else begin {$I-} BlockWrite(rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

function _wudata_chat(p:byte;clog_n:pcardinal;rpl:boolean):boolean;
var t,s:integer;
      i:cardinal;
begin
   _wudata_chat:=false;
   if(p<=MaxPlayers)then
    with _players[p] do
    begin
       if(log_n<clog_n^)then
        if(log_n=0)
        then clog_n^:=0
        else clog_n^:=log_n-1;

       if(log_n>clog_n^)then
       begin
          s:=min3(log_n,log_n-clog_n^,MaxPlayerLog);
          i:=log_i;
          clog_n^:=log_n;

          if(s>1)then
           for t:=1 to s-1 do
            if(i=0)
            then i:=MaxPlayerLog
            else i-=1;

          _wudata_byte(byte(s),rpl);
          for t:=1 to s do
          begin
             with log_l[i] do
             begin
                _wudata_byte  (mtype,rpl);
                _wudata_byte  (uidt ,rpl);
                _wudata_byte  (uid  ,rpl);
                _wudata_string(str  ,rpl);
                _wudata_byte  (byte(x shr 5),rpl);
                _wudata_byte  (byte(y shr 5),rpl);
             end;

             if(i=MaxPlayerLog)
             then i:=0
             else i+=1;
          end;
          if(rpl=false)then _wudata_card(clog_n^,rpl);
          _wudata_chat:=true;
          exit;
       end;
    end;
   _wudata_byte(0,rpl);
end;

procedure SetBBit(pb:pbyte;nb:byte;nozero:boolean);
var i:byte;
begin
   i:=(1 shl nb);
   if(nozero)
   then pb^:=pb^ or i
   else
     if((pb^ and i)>0)then pb^:=pb^ xor i;
end;


////////////////////////////////////////////////////////////////////////////////


procedure _wudata_bstat(pu:PTUnit;rpl:boolean;_pl:byte);
var _bts1,
    _bts2:byte;
begin
   with pu^ do
   with uid^ do
   begin
      _bts1:=0;
      _bts2:=0;

      SetBBit(@_bts2,0, buff[ub_stun     ]>0);
      SetBBit(@_bts2,1, buff[ub_resur    ]>0);
      SetBBit(@_bts2,2, buff[ub_summoned ]>0);
      SetBBit(@_bts2,3, buff[ub_invuln   ]>0);
      SetBBit(@_bts2,4, buff[ub_teleeff  ]>0);
      SetBBit(@_bts2,5, buff[ub_hvision  ]>0);

      SetBBit(@_bts1,0, bld                 );
      SetBBit(@_bts1,1, inapc>0             );
      SetBBit(@_bts1,2, buff[ub_advanced ]>0);
      SetBBit(@_bts1,3, buff[ub_pain     ]>0);
      SetBBit(@_bts1,4, buff[ub_cast     ]>0);
      SetBBit(@_bts1,5,(a_tar_cl>0)and(a_rld>0));
      SetBBit(@_bts1,6, sel                 );
      SetBBit(@_bts1,7, _bts2>0             );

      _wudata_byte(_bts1,rpl);
      if(_bts2>0)then _wudata_byte(_bts2,rpl);
   end;
end;

function _wrld(r:pinteger;rpl:boolean):byte;
begin
   if(r^<=0)
   then _wrld:=0
   else _wrld:=mm3(1,(r^ div fr_fps)+1,255);
   _wudata_byte(_wrld,rpl);
end;

procedure _wprod(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
   with uid^ do
   for i:=0 to MaxUnitProdsI do
   begin
      if(_isbarrack)then if(_wrld(@uprod_r[i],rpl)>0)then _wudata_byte(uprod_u[i],rpl);
      if(_issmith  )then if(_wrld(@pprod_r[i],rpl)>0)then _wudata_byte(pprod_u[i],rpl);
   end;
end;

procedure _wudata(pu:PTUnit;rpl:boolean;_pl:byte);
var sh :shortint;
    wt :word;
begin
   with pu^ do
   with uid^ do
   begin
      if(_uvision(_players[_pl].team,pu,true))or(rpl)
      then sh:=_Hi2Si(hits,_mhits,_shcf)
      else sh:=-128;

      _wudata_sint(sh,rpl);
      if(sh>-127)then
      begin
         _wudata_byte (uidi,rpl);
         _wudata_bstat(pu,rpl,_pl);

         if(inapc>0)
         then _wudata_int(inapc,rpl)
         else
           if(sh>0)then
           begin
              _wudata_int(vx ,rpl);
              _wudata_int(vy ,rpl);
           end
           else
           begin
              _wudata_byte(byte(vx shr 5),rpl);
              _wudata_byte(byte(vy shr 5),rpl);
           end;

         if(sh>0)then
         begin
            if(a_tar_cl>0)and(a_rld>0)then
            begin
               wt:=0;
               if(_IsUnitRange(a_tar_cl,nil))then wt:=word(a_tar_cl) and %0000001111111111;
               wt:=wt or ((word(a_weap_cl) shl 10) and %1111110000000000);
               _wudata_word(wt,rpl);
            end;

            if(buff[ub_cast]>0)then
             if(_ability in client_cast_abils)then
             begin
                _wrld(@rld,rpl);
                _wudata_int(uo_x ,rpl);
                _wudata_int(uo_y ,rpl);
             end;

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then _wudata_byte(group,rpl);
               if(_ukbuilding)then
               begin
                  if(bld)then
                  begin
                     if(_ability in client_rld_abils)then _wrld(@rld,rpl);
                     _wprod(pu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(pu^.uidi))then
                   if(_IsUnitRange(uo_tar,nil))
                   then _wudata_int(-uo_tar,rpl)
                   else
                   begin
                      _wudata_int(uo_x,rpl);
                      _wudata_int(uo_y,rpl);
                   end;
               end;
            end;

         end;
      end;
   end;
end;


procedure _wpupgr(rpl:boolean);
var i,n,bp,bv:byte;
begin
   for i:=1 to MaxPlayers do
    if((g_player_status and (1 shl i))>0)then
     with _players[i] do
     begin
        bp:=0;

        for n:=0 to 255 do
         if(race=_upids[n]._up_race)then
          case bp of
          0: begin
                bv:=upgr[n];
                bp:=1;
             end;
          1: begin
                bv:=bv or (upgr[n] shl 4);
                _wudata_byte(bv,rpl);
                bp:=0;
                bv:=0;
             end;
          end;

        if(bp=1)then _wudata_byte(bv,rpl);
     end;
end;

procedure _wclinet_gframe(_pl:byte;rpl:boolean);
var i: byte;
 gstp: cardinal;
 _N_U: pinteger;
 _PNU: integer;
begin
   _wudata_card(G_Step,rpl);

   gstp:=G_Step shr 1;
   if(rpl=false)then
    if((gstp mod fr_4hfps)=0)then
     with _players[_pl] do _wrld(@build_cd,rpl);

   if(rpl)
   then i:=fr_fps
   else i:=fr_2hfps;

   if((gstp mod i)=0)then
   begin
      case g_mode of
gm_invasion : begin
                 _wudata_byte(g_inv_wave_n,rpl);
                 _wudata_int (g_inv_time  ,rpl);
              end;
gm_royale   : _wudata_int(g_royal_r,rpl);
      end;
      if(g_mode=gm_capture)
      or(g_mode=gm_KotH)
      or(g_cgenerators>0)then
       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
        begin
           _wudata_byte(cpOwnerTeam,rpl);
           if(g_mode=gm_KotH)and(i=1)then _wudata_int(cpTimer,rpl);
           //+lifetime
        end;
   end;

   if(rpl)then
   begin
      _PNU:=_cl_pnua[rpls_pnui];
      _N_U:=@rpls_u;
   end
   else
   begin
      _PNU:= _players[_pl].PNU;
      _N_U:=@_players[_pl].n_u;
   end;

   CalcPLNU;;

   _wudata_byte(g_player_status,rpl);
   if(g_player_status>0)then
   begin
      _wudata_byte(_PNU,rpl);
      _PNU:=min2(g_cl_units,_PNU*4);

      if((gstp mod i)=0)then _wpupgr(rpl);

      _wudata_int(_N_U^,rpl);
      for i:=1 to _PNU do
      begin
         repeat
            inc(_N_U^,1);
            if (_N_U^<1)or(_N_U^>MaxUnits)then _N_U^:=1;
         until ( g_player_status and (1 shl ((_N_U^-1) div MaxPlayerUnits)) ) > 0 ;
         _wudata(@_units[_N_U^],rpl,_pl);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

function GetBBit(pb:pbyte;nb:byte):boolean;
begin
   GetBBit:=(pb^ and (1 shl nb))>0;
end;

procedure _ucInc(pu:PTUnit);
var i,_puid:byte;
    p:pinteger;
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

      if(_IsUnitRange(inapc,nil))then _units[inapc].apcc+=_apcs;

      if(hits>0)and(inapc<=0)then
      begin
         if(sel)then _unit_counters_inc_select(pu);
         if(bld=false)
         then cenergy-=_renergy
         else
         begin
            _unit_bld_inc_cntrs(pu);

            p:=@ucl_x[_ukbuilding,_ucl];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(_units[p^].uid^._ucl<>_ucl)then p^:=unum;

            p:=@uid_x[uidi];
            if(p^=0)
            then p^:=unum
            else if(0<p^)and(p^<=MaxUnits)then
                  if(_units[p^].uidi<>uidi)then p^:=unum;

            _unit_done_inc_cntrs(pu);

            if(_isbarrack)then
             for i:=0 to MaxUnitProdsI do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uproda+=1;
                 uprodc[_uids[_puid]._ucl]+=1;
                 uprodu[      _puid      ]+=1;
                 cenergy-=_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitProdsI do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i] ;

                 upproda+=1;
                 upprodu[_puid]+=1;
                 cenergy-=pprod_e[i];//_upids[_puid]._up_renerg;
              end;
         end;
      end;
   end;
end;

procedure _ucDec(pu:PTUnit);
var i,_puid:byte;
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

      if(_IsUnitRange(inapc,nil))then dec(_units[inapc].apcc,_apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then _unit_counters_dec_select(pu);
         if(bld=false)
         then cenergy+=_renergy
         else
         begin
            cenergy-=_genergy;
            menergy-=_genergy;
            uid_eb[uidi]-=1;
            ucl_eb[_ukbuilding,_ucl]-=1;
            if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
            if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;

            _unit_done_dec_cntrs(pu);

            if(_isbarrack)then
             for i:=0 to MaxUnitProdsI do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 uproda-=1;
                 uprodc[_uids[_puid]._ucl]-=1;
                 uprodu[      _puid      ]-=1;
                 cenergy+=_uids[_puid]._renergy;
              end;
            if(_issmith)then
             for i:=0 to MaxUnitProdsI do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i];

                 upproda-=1;
                 upprodu[_puid]-=1;
                 pprod_e[i]:=_upid_energy(_puid,upgr[_puid]+1);
                 cenergy+=pprod_e[i];
              end;
         end;
      end;
   end;
end;


procedure _ucSummonedEffect(uu:PTUnit;vis:pboolean);
begin
   with uu^ do
   begin
      vx:=x;
      vy:=y;
      _unit_summon_effects(uu,vis);
   end;
end;

procedure _teleEff(uu,pu:PTUnit);
begin
   with uu^  do
   begin
      vx:=x;
      vy:=y;
      if(uid^._ability=uab_hkeeptele)then
      begin
         teleport_effects(pu^.vx,pu^.vy,vx,vy,ukfly,EID_HKT_h,EID_HKT_s,snd_cube);
         buff[ub_clcast]:=fr_fps;
         exit;
      end;
      // default teleport effects
      teleport_effects(pu^.vx,pu^.vy,vx,vy,ukfly,EID_Teleport,EID_Teleport,snd_teleport)
   end;
end;

procedure _netSetUcl(uu:PTUnit);
var pu,tu:PTUnit;
   vis:boolean;
begin
   // pu - previous state
   // uu - current state
   pu:=@_units[0];
   with uu^ do vis:=PointInScreenP(x,y,player);
   with uu^ do
    with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // create unit
     begin
        _unit_default(uu);

        if(_IsUnitRange(inapc,@tu))then _unit_inapc_target(uu,tu);

        vx:=x;
        vy:=y;

        _unit_upgr(uu);

        if(hits>0)then
        begin
           _unit_fog_r(uu);
           if(buff[ub_summoned]>0)then _ucSummonedEffect(uu,@vis);
           if(buff[ub_teleeff ]>0)then _teleEff(uu,@vis);
           if(buff[ub_hvision ]>0)then _unit_HvisionEff(uu,@vis);
           with uid^ do
           if(bld=false)then SoundPlayAnoncer(snd_build_place[_urace],false);

           if(sel)and(playeri=HPlayer)then ui_UnitSelectedNU:=unum;
        end;

        _ucInc(uu);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // remove unit
       begin
          _unit_upgr(pu);

          vx:=x;
          vy:=y;
          if(pu^.hits>0)and(vis)then
          begin
             if(hits>ndead_hits)and(inapc=0)then
             begin
                if(buff[ub_teleeff]>0)then _teleEff(uu,@vis);

                _unit_death_effects(uu,true,@vis);
             end;
          end;

          if(playeri=HPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;

          _ucDec(pu);
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;
            end;

            _unit_upgr(pu);
            _ucDec(pu);

            _unit_upgr(uu);
            _ucInc(uu);

            if(hits>0)then
            begin
               if(pu^.buff[ub_teleeff ]<=0)and(buff[ub_teleeff ]>0)then _teleEff(uu,pu);
               if(pu^.buff[ub_summoned]<=0)and(buff[ub_summoned]>0)then _ucSummonedEffect (uu,@vis);
               if(pu^.buff[ub_hvision ]<=0)and(buff[ub_hvision ]>0)then _unit_HvisionEff  (uu,@vis);
               if(pu^.buff[ub_pain    ]<=0)and(buff[ub_pain    ]>0)then _unit_pain_effects(uu,@vis);

               if(pu^.bld)and(bld=false)then
                if(playeri=HPlayer)then
                 with uid^ do SoundPlayAnoncer(snd_build_place[_urace],false);

               if(pu^.sel=false)and(sel)and(playeri=HPlayer)then ui_UnitSelectedNU:=unum;
               if(pu^.inapc<>inapc)and(vis)then SoundPlayUnit(snd_inapc,nil,@vis);

               if(bld)then
               begin
                  if(pu^.buff[ub_cast]<=0)and(buff[ub_cast]>0)then
                   case uid^._ability of
               0:;
               uab_uac_rstrike : _unit_umstrike_missile(uu);
               uab_radar       : if(team=_players[HPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
               uab_spawnlost   : _ability_unit_spawn(pu,UID_LostSoul);
                   end;

                  if(uid^._ukbuilding=false)then
                  begin
                     if(uid^._ability<>uab_advance)then
                      if(pu^.buff[ub_advanced]<=0)and(buff[ub_advanced]>0)then
                      begin
                         case uid^._urace of
                    r_hell: _unit_PowerUpEff(pu,snd_unit_adv[uid^._urace],@vis);
                    r_uac : SoundPlayUnit(snd_unit_adv[uid^._urace],pu,@vis);
                         end;
                      end;

                     if(pu^.buff[ub_invuln]<=0)and(buff[ub_invuln]>0)then _unit_PowerUpEff(uu,snd_hell_invuln,@vis);
                  end;
               end;
            end;

            if(pu^.hits<=0)and(hits>0)then
            begin
               _unit_fog_r(uu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buff[ub_resur]=0)then
              begin
                 _unit_death_effects(uu,hits<=fdead_hits,@vis);
                 if(playeri=HPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
                 rld:=0;
              end;

            if(not _IsUnitRange(pu^.inapc,nil))then
             if(_IsUnitRange(inapc,@tu))then _unit_inapc_target(uu,tu);

            if(speed>0)then
            begin
               uo_bx:=pu^.x;
               uo_by:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               _unit_SetXY(uu,x,y,mvxy_none);

               if(speed>0)then
               begin
                  vstp:=UnitStepTicks;
                  dir :=point_dir(uo_bx,uo_by,x,y);
               end;
            end;
         end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function _rudata_string(rpl:boolean):shortstring;
var sl,x:byte;
       c:char;
begin
   if(rpl=false)
   then _rudata_string:=net_readstring
   else
   begin
      sl:=0;
      _rudata_string:='';
      {$I-}
      BlockRead(rpls_file,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=#0;
         BlockRead(rpls_file,c,SizeOf(c));
         _rudata_string:=_rudata_string+c;
      end;
      {$I+}
   end;
end;

function _rudata_byte(rpl:boolean;def:byte):byte;
begin
   if(rpl=false)
   then _rudata_byte:=net_readbyte
   else begin {$I-} BlockRead(rpls_file,_rudata_byte,SizeOf(_rudata_byte));if(ioresult<>0)then _rudata_byte:=def; {$I+} end;
end;

function _rudata_word(rpl:boolean;def:word):word;
begin
   if(rpl=false)
   then _rudata_word:=net_readword
   else begin {$I-} BlockRead(rpls_file,_rudata_word,SizeOf(_rudata_word));if(ioresult<>0)then _rudata_word:=def; {$I+} end;
end;

function _rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   if(rpl=false)
   then _rudata_sint:=net_readsint
   else begin {$I-} BlockRead(rpls_file,_rudata_sint,SizeOf(_rudata_sint));if(ioresult<>0)then _rudata_sint:=def; {$I+} end;
end;

function _rudata_int(rpl:boolean;def:integer):integer;
begin
   if(rpl=false)
   then _rudata_int:=net_readint
   else begin {$I-} BlockRead(rpls_file,_rudata_int ,SizeOf(_rudata_int ));if(ioresult<>0)then _rudata_int :=def; {$I+} end;
end;

function _rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   if(rpl=false)
   then _rudata_card:=net_readcard
   else begin {$I-} BlockRead(rpls_file,_rudata_card,SizeOf(_rudata_card));if(ioresult<>0)then _rudata_card:=def; {$I+} end;
end;

procedure  _rudata_chat(p:byte;rpl:boolean);
var s,
mtype,
uidt,
uid,x,y:byte;
    str:shortstring;
begin
   s:=_rudata_byte(rpl,0);
   if(s>0)then
   begin
      while(s>0)do
      begin
         mtype:=_rudata_byte  (rpl,0);
         uidt :=_rudata_byte  (rpl,0);
         uid  :=_rudata_byte  (rpl,0);
         str  :=_rudata_string(rpl  );
         x    :=_rudata_byte  (rpl,0);
         y    :=_rudata_byte  (rpl,0);
         PlayerAddLog(p,mtype,uidt,uid,str,x shl 5,y shl 5,false);
         s-=1;
      end;
      if(rpl=false)then
       if(p<=MaxPlayers)
       then with _players[p] do log_n:=_rudata_card(rpl,log_n)
       else _rudata_card(rpl,0);
   end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure _rudata_bstat(uu:PTUnit;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with uu^ do
   begin
      a_weap:=255;

      _bts1:=_rudata_byte(rpl,0);

      bld:=GetBBit(@_bts1,0);
      if(GetBBit(@_bts1,1))then inapc:=1 else inapc:=0;
      buff[ub_advanced ]:=_buffst[GetBBit(@_bts1,2)];
      buff[ub_pain     ]:=_buffst[GetBBit(@_bts1,3)];
      buff[ub_cast     ]:=_buffst[GetBBit(@_bts1,4)];
      if(GetBBit(@_bts1,5))then a_tar:=-1 else a_tar:=0;
      sel:=GetBBit(@_bts1,6);
      if(GetBBit(@_bts1,7))
      then _bts2:=_rudata_byte(rpl,0)
      else _bts2:=0;

      if(_bts2>0)then
      begin
         buff[ub_stun     ]:=_buffst[GetBBit(@_bts2,0)];
         buff[ub_resur    ]:=_buffst[GetBBit(@_bts2,1)];
         buff[ub_summoned ]:=_buffst[GetBBit(@_bts2,2)];
         buff[ub_invuln   ]:=_buffst[GetBBit(@_bts2,3)];
         buff[ub_teleeff  ]:=_buffst[GetBBit(@_bts2,4)];
         buff[ub_hvision  ]:=_buffst[GetBBit(@_bts2,5)];
      end
      else
      begin
         buff[ub_stun     ]:=0;
         buff[ub_resur    ]:=0;
         buff[ub_summoned ]:=0;
         buff[ub_invuln   ]:=0;
         buff[ub_teleeff  ]:=0;
         buff[ub_hvision  ]:=0;
      end;

      if(rpl=false)then _AddToInt(@vsnt[_players[HPlayer].team],vistime);
   end;
end;

function _rrld(r:pinteger;rpl:boolean):byte;
begin
   _rrld  :=_rudata_byte(rpl,0);
   if(_rrld=0)
   then r^:=0
   else r^:=_rrld*fr_fps-1;
end;

procedure _rprod(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
   with uid^ do
   for i:=0 to MaxUnitProdsI do
   begin
      if(_isbarrack)then if(_rrld(@uprod_r[i],rpl)>0)then uprod_u[i]:=_rudata_byte(rpl,0);
      if(_issmith  )then if(_rrld(@pprod_r[i],rpl)>0)then pprod_u[i]:=_rudata_byte(rpl,0);
   end;
end;

procedure _rudata(uu:PTUnit;rpl:boolean;_pl:byte);
var sh:shortint;
    i :byte;
    wt:word;
    tu:PTUnit;
begin
   _units[0]:=uu^;
   with uu^ do
   begin
      playeri:=(unum-1) div MaxPlayerUnits;
      player :=@_players[playeri];
      sh:=_rudata_sint(rpl,-128);
      if(sh>-127)then
      begin
         i   :=uidi;
         uidi:=_rudata_byte(rpl,0);
         if(i<>uidi)then
         begin
            _unit_apUID(uu,false);
            _unit_default(uu);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_Si2Hi(sh,uid^._mhits,uid^._shcf);
         _rudata_bstat(uu,rpl);

         if(inapc>0)then
         begin
            inapc:=_rudata_int(rpl,0);
            if(_IsUnitRange(inapc,nil)=false)then inapc:=0;
         end
         else
           if(sh>0)then
           begin
              x:=_rudata_int(rpl,x);
              y:=_rudata_int(rpl,y);
           end
           else
           begin
              x:=integer(_rudata_byte(rpl,0) shl 5)+(x mod 32);
              y:=integer(_rudata_byte(rpl,0) shl 5)+(y mod 32);
           end;

         if(sh>0)then
         begin
            if(a_tar=-1)then
            begin
               wt:=_rudata_word(rpl,0);
               a_tar :=integer(wt and %0000001111111111);
               a_weap:=(wt and %1111110000000000) shr 10;
            end;

            if(buff[ub_cast]>0)then
             if(uid^._ability in client_cast_abils)then
             begin
                _rrld(@rld,rpl);
                uo_x:=_rudata_int(rpl,0);
                uo_y:=_rudata_int(rpl,0);
             end;

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then group:=_rudata_byte(rpl,0);
               if(uid^._ukbuilding)then
               begin
                  if(bld)then
                  begin
                     if(uid^._ability in client_rld_abils)then _rrld(@rld,rpl);
                     _rprod(uu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(uu^.uidi))then
                  begin
                     uo_x:=_rudata_int(rpl,0);
                     if(_IsUnitRange(-uo_x,@tu))then
                     begin
                        uo_tar:=-uo_x;
                        uo_x  :=tu^.vx;
                        uo_y  :=tu^.vy;
                     end
                     else
                     begin
                        uo_tar:=0;
                        uo_y  :=_rudata_int(rpl,0);
                     end;
                  end;
               end;
            end;
         end;
      end
      else hits:=ndead_hits;
      if(rpl)and(rpls_step>2)then
      begin
         vx:=x;
         vy:=y;
      end;
   end;
   _netSetUcl(uu);
end;


procedure _rpdata(rpl:boolean);
var i,n,bp,bv:byte;
begin
   if(g_player_status>0)then
   for i:=1 to MaxPlayers do
    if((g_player_status and (1 shl i))>0)then
     with _players[i] do
     begin
        bp:=0;

        for n:=0 to 255 do
        with _upids[n] do
         if(race=_up_race)then
         case bp of
         0: begin
               bv:=_rudata_byte(rpl,0);
               upgr[n]:=min2(_up_max,bv and %00001111);
               bp:=1;
            end;
         1: begin
               upgr[n]:=min2(_up_max,bv shr 4);
               bp:=0;
            end;
         end;
     end;
end;

procedure ClNUnits;
var i:byte;
begin
   g_cl_units:=0;
   for i:=1 to MaxPlayers do
    if((g_player_status and (1 shl i))>0)then inc(g_cl_units,MaxPlayerUnits);
end;

procedure _rclinet_gframe(_pl:byte;rpl:boolean);
var gstp: cardinal;
    i   : byte;
    _PNU,
    _N_U: integer;
begin
   G_Step:=_rudata_card(rpl,G_Step);

   gstp:=G_Step shr 1;
   if(rpl=false)then
    if((gstp mod fr_4hfps)=0)then
     with _players[_pl] do
     begin
         _rrld(@build_cd,rpl);
     end;

   if(rpl)
   then i:=fr_fps
   else i:=fr_2hfps;

   if((gstp mod i)=0)then
   begin
      case g_mode of
gm_invasion : begin
                 _PNU:=g_inv_wave_n;
                 g_inv_wave_n:=_rudata_byte(rpl,0);
                 if(g_inv_wave_n>_PNU)then SoundPlayUnit(snd_teleport,nil,nil);
                 g_inv_time :=_rudata_int (rpl,0);
              end;
gm_royale   : g_royal_r:=_rudata_int(rpl,0);
      end;
      if(g_mode=gm_capture)
      or(g_mode=gm_KotH)
      or(g_cgenerators>0)then
       for i:=1 to MaxCPoints do
        with g_cpoints[i] do
        begin
           cpOwnerTeam:=_rudata_byte(rpl,0);
           if(g_mode=gm_KotH)and(i=1)then cpTimer:=_rudata_int(rpl,0);
           //lifetime
        end;
   end;

   g_player_status:=_rudata_byte(rpl,0);
   if(g_player_status>0)then
   begin
      _PNU:=_rudata_byte(rpl,0)*4;

      if(_PNU<0)then exit;

      ClNUnits;

      if(_PNU>g_cl_units)then _PNU:=g_cl_units;

      if(_PNU<>rpls_pnu)then
      begin
         rpls_pnu:=_PNU;
         if(rpls_pnu<=0)then rpls_pnu:=1;
         UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN+1;
         if(UnitStepTicks=0)then UnitStepTicks:=1;
      end;

      if((gstp mod i)=0)then _rpdata(rpl);

      _N_U:=_rudata_int(rpl,0);
      for i:=1 to _PNU do
      begin
         repeat
           inc(_N_U,1);
           if(_N_U<1)or(_N_U>MaxUnits)then _N_U:=1;
         until ( g_player_status and (1 shl ((_N_U-1) div MaxPlayerUnits)) ) > 0 ;
         _units[_N_U].unum:=_N_U;
         _rudata(@_units[_N_U],rpl,_pl);
      end;
   end;
end;
{$ENDIF}


