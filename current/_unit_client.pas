
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
      BlockWrite(_rpls_file,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=s[x];
         BlockWrite(_rpls_file,c,SizeOf(c));
      end;
      {$I+}
   end;
end;

procedure _wudata_chat(p:byte;rpl:boolean);
var i:byte;
begin
   if(rpl=false)
   then net_writechat(p)
   else for i:=0 to MaxNetChat do _wudata_string(net_chat[p,i],rpl);
end;

procedure _wudata_byte(bt:byte;rpl:boolean);
begin
   if(rpl=false)
   then net_writebyte(bt)
   else begin {$I-} BlockWrite(_rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_sint(bt:shortint;rpl:boolean);
begin
   if(rpl=false)
   then net_writesint(bt)
   else begin {$I-} BlockWrite(_rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_int(bt:integer;rpl:boolean);
begin
   if(rpl=false)
   then net_writeint(bt)
   else begin {$I-} BlockWrite(_rpls_file,bt,SizeOf(bt)); {$I+} end;
end;

procedure _wudata_card(bt:cardinal;rpl:boolean);
begin
   if(rpl=false)
   then net_writecard(bt)
   else begin {$I-} BlockWrite(_rpls_file,bt,SizeOf(bt)); {$I+} end;
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

      SetBBit(@_bts2,0, buff[ub_stun    ]>0);
      SetBBit(@_bts2,1, buff[ub_gear     ]>0);
      SetBBit(@_bts2,2, buff[ub_resur    ]>0);
      SetBBit(@_bts2,3, buff[ub_born     ]>0);
      SetBBit(@_bts2,4, buff[ub_invuln   ]>0);
      SetBBit(@_bts2,5, buff[ub_teleeff  ]>0);

      SetBBit(@_bts1,0, bld                 );
      SetBBit(@_bts1,1, inapc>0             );
      SetBBit(@_bts1,2, buff[ub_advanced ]>0);
      SetBBit(@_bts1,3, buff[ub_pain     ]>0);
      SetBBit(@_bts1,4, buff[ub_cast     ]>0);
      SetBBit(@_bts1,5,(a_tar>0)and(a_rld>0));
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
   else _wrld:=min2((r^ div fr_fps)+1,255);
   _wudata_byte(_wrld,rpl);
end;

procedure _wprod(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
   with uid^ do
   for i:=0 to MaxUnitProds do
   begin
      if(_isbarrack)then if(_wrld(@uprod_r[i],rpl)>0)then _wudata_byte(uprod_u[i],rpl);
      if(_issmith  )then if(_wrld(@pprod_r[i],rpl)>0)then _wudata_byte(pprod_u[i],rpl);
   end;
end;

procedure _wudata(pu:PTUnit;rpl:boolean;_pl:byte);
var sh :shortint;
begin
   with pu^ do
   with uid^ do
   begin
      if(_uvision(_players[_pl].team,pu,true))or(rpl)
      then sh:=_hi2S(hits,_mhits,_shcf)
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
            if(a_tar>0)and(a_rld>0)then _wudata_int(a_tar,rpl);

            if(buff[ub_cast]>0)then
             if(_ability in client_cast_abils)then
             begin
                _wrld(@rld,rpl);
                _wudata_int(uo_x ,rpl);
                _wudata_int(uo_y ,rpl);
             end;

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then _wudata_byte(order,rpl);
               if(_isbuilding)then
               begin
                  if(bld)then
                  begin
                     if(_ability in client_rld_abils)then _wrld(@rld,rpl);
                     _wprod(pu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(pu^.uidi))then
                  begin
                     _wudata_int(uo_x ,rpl);
                     _wudata_int(uo_y ,rpl);
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
    if((G_plstat and (1 shl i))>0)then
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
    if((gstp mod fr_hhfps)=0)then
     with _players[_pl] do _wrld(@build_cd,rpl);

   if(rpl)
   then i:=fr_fps
   else i:=fr_hfps;

   if((gstp mod i)=0)then
    case g_mode of
gm_inv : begin
            _wudata_byte(g_inv_wave_n,rpl);
            _wudata_int (g_inv_time  ,rpl);
         end;
gm_ct  : for i:=1 to MaxCPoints do _wudata_byte(g_cpoints[i].pl,rpl);
gm_royl: _wudata_int(g_royal_r,rpl);
    end;

   if(rpl)then
   begin
      _PNU:=_cl_pnua[_rpls_pnui];
      _N_U:=@_rpls_u;
   end
   else
   begin
      _PNU:= _players[_pl].PNU;
      _N_U:=@_players[_pl].n_u;
   end;

   CalcPLNU;

   _wudata_byte(G_plstat,rpl);
   if(G_plstat>0)then
   begin
      _wudata_byte(_PNU,rpl);
      _PNU:=min2(G_nunits,_PNU*4);

      if((gstp mod i)=0)then _wpupgr(rpl);

      _wudata_int(_N_U^,rpl);
      for i:=1 to _PNU do
      begin
         repeat
            inc(_N_U^,1);
            if (_N_U^<1)or(_N_U^>MaxUnits)then _N_U^:=1;
         until ( G_plstat and (1 shl ((_N_U^-1) div MaxPlayerUnits)) ) > 0 ;
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
      inc(uid_e[uidi],1);
      inc(ucl_e[_isbuilding,_ucl],1);
      inc(ucl_c[_isbuilding],1);
      inc(army,1);

      if(_IsUnitRange(inapc,nil))then inc(_units[inapc].apcc,_apcs);

      if(hits>0)and(inapc<=0)then
      begin
         if(sel)then _unit_inc_selc(pu);
         if(bld=false)
         then dec(cenerg,_renerg)
         else
         begin
            _unit_bld_inc_cntrs(pu);

            p:=@ucl_x[_isbuilding,_ucl];
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
             for i:=0 to MaxUnitProds do
              if(uprod_r[i]>0)then
              begin
                 _puid:=uprod_u[i];

                 inc(uproda,1);
                 inc(uprodc[_uids[_puid]._ucl],1);
                 inc(uprodu[_puid],1);
                 dec(cenerg,_uids[_puid]._renerg);
              end;
            if(_issmith)then
             for i:=0 to MaxUnitProds do
              if(pprod_r[i]>0)then
              begin
                 _puid:=pprod_u[i] ;

                 inc(pproda,1);
                 inc(pprodu[_puid],1);
                 dec(cenerg,_upids[_puid]._up_renerg);
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
      dec(uid_e[uidi],1);
      dec(ucl_e[_isbuilding,_ucl],1);
      dec(ucl_c[_isbuilding],1);
      dec(army,1);

      if(_IsUnitRange(inapc,nil))then dec(_units[inapc].apcc,_apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then _unit_dec_selc(pu);
         if(bld=false)
         then inc(cenerg,_renerg)
         else
         begin
            dec(cenerg,_generg);
            dec(menerg,_generg);
            dec(uid_eb[uidi],1);
            dec(ucl_eb[_isbuilding,_ucl],1);
            if(ucl_x[_isbuilding,_ucl]=unum)then ucl_x[_isbuilding,_ucl]:=0;
            if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;

            _unit_done_dec_cntrs(pu);

             if(_isbarrack)then
              for i:=0 to MaxUnitProds do
               if(uprod_r[i]>0)then
               begin
                  _puid:=uprod_u[i];

                  dec(uproda,1);
                  dec(uprodc[_uids[_puid]._ucl],1);
                  dec(uprodu[_puid],1);
                  inc(cenerg,_uids[_puid]._renerg);
               end;
             if(_issmith)then
              for i:=0 to MaxUnitProds do
               if(pprod_r[i]>0)then
               begin
                  _puid:=pprod_u[i];

                  dec(pproda,1);
                  dec(pprodu[_puid],1);
                  inc(cenerg,_upids[_puid]._up_renerg);
               end;
         end;
      end;
   end;
end;


procedure _ucCreateEffect(uu:PTUnit;vis:pboolean);
begin
   with uu^     do
   begin
      vx:=x;
      vy:=y;
      _unit_ready_effects(uu,vis);
   end;
end;

procedure _teleEff(pu:PTUnit;vis:pboolean);
begin
   with pu^ do
   begin
      vx:=x;
      vy:=y;
      _effect_add(vx,vy,_depth(vy+1,uf),EID_Teleport);
      PlaySND(snd_teleport,nil,vis);
   end;
end;

procedure _netSetUcl(uu:PTUnit);
var pu,tu:PTUnit;
   vis:boolean;
begin
   pu:=@_units[0];
   with uu^ do vis:=_nhp3(x,y,player);
   with uu^ do
    with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // create unit
     begin
        _unit_default(uu);

        if(_IsUnitRange(inapc,@tu))then _unit_asapc(uu,tu);

        vx:=x;
        vy:=y;

        _unit_upgr(uu);

        if(hits>0)then
        begin
           _unit_fog_r(uu);
           if(buff[ub_born]>0)then _ucCreateEffect(uu,@vis);

           if(buff[ub_teleeff]>0)then _teleEff(uu,@vis);
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

             if(hits<=ndead_hits)and(pu^.uid^._ability=uab_morph2heye)and(buff[ub_cast]>0)then _pain_lost_fail(vx,vy,_depth(vy+1,uf),@vis);
          end;

          if(playeri=HPlayer)and(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;

          _ucDec(pu);

          {x :=-32000;
          y :=-32000;
          vx:=x;
          vy:=y; }
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               vx:=x;
               vy:=y;

               if(pu^.uid^._ability=uab_morph2heye)and(buff[ub_cast]>0)then _pain_lost_fail(pu^.vx,pu^.vy,_depth(pu^.vy+1,pu^.uf),@vis);
            end;

            _unit_upgr(pu);
            _ucDec(pu);

            _unit_upgr(uu);
            _ucInc(uu);

            if(hits>0)then
            begin
               if(pu^.buff[ub_teleeff]<=0)and(buff[ub_teleeff]>0)then _teleEff(uu,@vis);

               if((pu^.buff[ub_born]<=0)and(buff[ub_born]>0))then _ucCreateEffect(uu,@vis);

               if(pu^.sel=false)and(sel)and(playeri=HPlayer)then ui_UnitSelectedNU:=unum;
               if(pu^.inapc<>inapc)and(vis)then PlaySND(snd_inapc,nil,@vis);

               if(bld)then
               begin
                  if(pu^.buff[ub_cast]<=0)and(buff[ub_cast]>0)then
                   case uid^._ability of
               0:;
               uab_uac_rstrike : _unit_umstrike_create(uu);
               uab_radar       : if(team=_players[HPlayer].team)then PlaySND(snd_radar,nil,@vis);
               uab_spawnlost   : _ability_unit_spawn(pu,UID_LostSoul);
                   end;

                  if(uid^._isbuilding=false)then
                  begin
                     if(pu^.buff[ub_advanced]=0)and(buff[ub_advanced ]>0)then
                      case uid^._urace of
                r_hell: _unit_hell_unit_adv(uu);
                r_uac : _unit_uac_unit_adv (uu,nil);
                      end;

                     if(pu^.buff[ub_invuln  ]=0)and(buff[ub_invuln  ]>0)then _unit_PowerUpEff(uu,snd_hell_invuln);
                  end;

                  {if(uidi in [UID_Major,UID_ZMajor])then
                   if(pu^.hits>0)then
                   begin
                      if(pu^.uf=uf_ground)and(uf>uf_ground)then PlaySND(snd_jetpon ,uu,@vis);
                      if(pu^.uf>uf_ground)and(uf=uf_ground)then PlaySND(snd_jetpoff,uu,@vis);
                   end;}
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

            if(pu^.inapc=0)then
             if(_IsUnitRange(inapc,@tu))then _unit_asapc(uu,tu);

            {
            if(uidi in [UID_UCommandCenter,UID_HCommandCenter])then
            begin
               if(pu^.buff[ub_advanced]=0)and(buff[ub_advanced]>0)then
               begin
                  speed:= 6;
                  uf   := uf_fly;
                  buff[ub_clcast]  := uaccc_fly;
                  PlaySND(snd_ccup,uu);
               end;
               if(pu^.buff[ub_advanced]>0)and(buff[ub_advanced]=0)then
               begin
                  speed:= 0;
                  uf   := uf_ground;
                  buff[ub_clcast]  := uaccc_fly;
                  vy:=y;
                  PlaySND(snd_inapc,uu);
               end;
               if(buff[ub_advanced]>0)then
               begin
                  speed:=6;
                  uf   := uf_fly;
               end;
            end;
   }

            if(speed>0)then
            begin
               uo_bx:=pu^.x;
               uo_by:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               _unit_sfog(uu);
               _unit_mmcoords(uu);

               {if(pu^.buff[ub_teleeff]=0)and(buff[ub_teleeff]>0)then
                if(uidi=UID_HKeep)then
                begin
                   if(_nhp3(x,y,player))
                   or(_nhp3(pu^.x,pu^.y,player))then PlaySND(snd_cubes,nil);
                   _effect_add(pu^.x,pu^.y,0,EID_HKT_h);
                   _effect_add(x    ,y    ,0,EID_HKT_s);
                   buff[ub_clcast]:=vid_fps;
                   vx:=x;
                   vy:=y;
                end
                else
                begin
                   vx:=x;
                   vy:=y;
                   if(_nhp3(vx,vy,player))
                   or(_nhp3(pu^.vx,pu^.vy,player))then PlaySND(snd_teleport,nil);
                   _effect_add(vx    ,vy    ,    vy+map_flydpth[uf]+1,EID_Teleport);
                   _effect_add(pu^.vx,pu^.vy,pu^.vy+map_flydpth[uf]+1,EID_Teleport);
                end; }

               if(speed>0)then
               begin
                  vstp:=UnitStepNum;

                  dir :=p_dir(uo_bx,uo_by,x,y);
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
      BlockRead(_rpls_file,sl,SizeOf(sl));
      for x:=1 to sl do
      begin
         c:=#0;
         BlockRead(_rpls_file,c,SizeOf(c));
         _rudata_string:=_rudata_string+c;
      end;
      {$I+}
   end;
end;

procedure  _rudata_chat(p:byte;rpl:boolean);
var i:byte;
begin
   if(rpl=false)
   then net_readchat(p)
   else for i:=0 to MaxNetChat do net_chat[p,i]:=_rudata_string(rpl);
end;

function _rudata_byte(rpl:boolean;def:byte):byte;
begin
   if(rpl=false)
   then _rudata_byte:=net_readbyte
   else begin {$I-} BlockRead(_rpls_file,_rudata_byte,SizeOf(_rudata_byte));if(ioresult<>0)then _rudata_byte:=def; {$I+} end;
end;

function _rudata_sint(rpl:boolean;def:shortint):shortint;
begin
   if(rpl=false)
   then _rudata_sint:=net_readsint
   else begin {$I-} BlockRead(_rpls_file,_rudata_sint,SizeOf(_rudata_sint));if(ioresult<>0)then _rudata_sint:=def; {$I+} end;
end;

function _rudata_int(rpl:boolean;def:integer):integer;
begin
   if(rpl=false)
   then _rudata_int:=net_readint
   else begin {$I-} BlockRead(_rpls_file,_rudata_int ,SizeOf(_rudata_int ));if(ioresult<>0)then _rudata_int :=def; {$I+} end;
end;

function _rudata_card(rpl:boolean;def:cardinal):cardinal;
begin
   if(rpl=false)
   then _rudata_card:=net_readcard
   else begin {$I-} BlockRead(_rpls_file,_rudata_card,SizeOf(_rudata_card));if(ioresult<>0)then _rudata_card :=def; {$I+} end;
end;

////////////////////////////////////////////////////////////////////////////////


procedure _rudata_bstat(uu:PTUnit;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with uu^ do
   begin
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
         buff[ub_stun    ]:=_buffst[GetBBit(@_bts2,0)];
         buff[ub_gear     ]:=_buffst[GetBBit(@_bts2,1)];
         buff[ub_resur    ]:=_buffst[GetBBit(@_bts2,2)];
         buff[ub_born     ]:=_buffst[GetBBit(@_bts2,3)];
         buff[ub_invuln   ]:=_buffst[GetBBit(@_bts2,4)];
         buff[ub_teleeff  ]:=_buffst[GetBBit(@_bts2,5)];
      end
      else
      begin
         buff[ub_stun    ]:=0;
         buff[ub_gear     ]:=0;
         buff[ub_resur    ]:=0;
         buff[ub_born     ]:=0;
         buff[ub_invuln   ]:=0;
         buff[ub_teleeff  ]:=0;
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
   for i:=0 to MaxUnitProds do
   begin
      if(_isbarrack)then if(_rrld(@uprod_r[i],rpl)>0)then uprod_u[i]:=_rudata_byte(rpl,0);
      if(_issmith  )then if(_rrld(@pprod_r[i],rpl)>0)then pprod_u[i]:=_rudata_byte(rpl,0);
   end;
end;

procedure _rudata(uu:PTUnit;rpl:boolean;_pl:byte);
var sh:shortint;
    i :byte;
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
            _unit_apUID(uu);
            _unit_default(uu);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_S2hi(sh,uid^._mhits,uid^._shcf);
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
               a_tar:=_rudata_int(rpl,0);
               if(_IsUnitRange(a_tar,nil)=false)then a_tar:=0;
            end;

            if(uid^._ability in client_cast_abils)then
             if(buff[ub_cast]>0)then
             begin
                _rrld(@rld,rpl);
                uo_x:=_rudata_int(rpl,0);
                uo_y:=_rudata_int(rpl,0);
             end;

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then order:=_rudata_byte(rpl,0);
               if(uid^._isbuilding)then
               begin
                  if(bld)then
                  begin
                     if(uid^._ability in client_rld_abils)then _rrld(@rld,rpl);
                     _rprod(uu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(uu^.uidi))then
                  begin
                     uo_x:=_rudata_int(rpl,0);
                     uo_y:=_rudata_int(rpl,0);
                  end;
               end;
            end;
         end;
      end
      else hits:=ndead_hits;
      if(rpl)and(_rpls_step>2)then
      begin
         vx:=x;
         vy:=y;
      end;
   end;
   _netSetUcl(uu);
end;


procedure _rpdata(rpl:boolean);
var i,n,bp,bv,lu,anoncer:byte;
begin
   anoncer:=0;
   if(G_plstat>0)then
   for i:=1 to MaxPlayers do
    if((G_plstat and (1 shl i))>0)then
     with _players[i] do
     begin
        bp:=0;

        for n:=0 to 255 do
        with _upids[n] do
         if(race=_up_race)then
         case bp of
         0: begin
               bv:=_rudata_byte(rpl,0);
               lu:=upgr[n];
               upgr[n]:=min2(_up_max,bv and %00001111);
               if(upgr[n]>lu)and(i=HPlayer)then anoncer:=race;
               bp:=1;
            end;
         1: begin
               lu:=upgr[n];
               upgr[n]:=min2(_up_max,bv shr 4);
               if(upgr[n]>lu)and(i=HPlayer)then anoncer:=race;
               bp:=0;
            end;
         end;
     end;

   if(anoncer>0)then PlayInGameAnoncer(snd_upgrade_complete[anoncer]);
end;

procedure ClNUnits;
var i:byte;
begin
   G_nunits:=0;
   for i:=1 to MaxPlayers do
    if((G_plstat and (1 shl i))>0)then inc(G_nunits,MaxPlayerUnits);
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
    if((gstp mod fr_hhfps)=0)then
     with _players[_pl] do
     begin
         _rrld(@build_cd,rpl);
     end;

   if(rpl)
   then i:=fr_fps
   else i:=fr_hfps;

   if((gstp mod i)=0)then
    case g_mode of
gm_inv : begin
            _PNU:=g_inv_wave_n;
            g_inv_wave_n:=_rudata_byte(rpl,0);
            if(g_inv_wave_n>_PNU)then PlaySND(snd_teleport,nil,nil);
            g_inv_time :=_rudata_int (rpl,0);
         end;
gm_ct  : for i:=1 to MaxCPoints do g_cpoints[i].pl:=_rudata_byte(rpl,0);
gm_royl: g_royal_r:=_rudata_int(rpl,0);
    end;

   G_plstat:=_rudata_byte(rpl,0);
   if(G_plstat>0)then
   begin
      _PNU:=_rudata_byte(rpl,0)*4;

      if(_PNU<0)then exit;

      ClNUnits;

      if(_PNU>G_nunits)then _PNU:=G_nunits;

      if(_PNU<>_rpls_pnu)then
      begin
         _rpls_pnu:=_PNU;
         if(_rpls_pnu<=0)then _rpls_pnu:=1;
         UnitStepNum:=trunc(MaxUnits/_rpls_pnu)*NetTickN+1;
         if(UnitStepNum=0)then UnitStepNum:=1;
      end;

      if((gstp mod i)=0)then _rpdata(rpl);

      _N_U:=_rudata_int(rpl,0);
      for i:=1 to _PNU do
      begin
         repeat
           inc(_N_U,1);
           if(_N_U<1)or(_N_U>MaxUnits)then _N_U:=1;
         until ( G_plstat and (1 shl ((_N_U-1) div MaxPlayerUnits)) ) > 0 ;
         _units[_N_U].unum:=_N_U;
         _rudata(@_units[_N_U],rpl,_pl);
      end;
   end;
end;
{$ENDIF}


