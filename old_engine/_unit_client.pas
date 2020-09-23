
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

procedure _wudata_bstat(u:integer;rpl:boolean;_pl:byte);
var _bts1,
    _bts2:byte;
begin
   with _units[u] do
   begin
      _bts1:=0;
      _bts2:=0;

      SetBBit(@_bts2,0, buff[ub_toxin    ]>0);
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
      SetBBit(@_bts1,5, (uid in whocanattack)and(tar1>0));
      SetBBit(@_bts1,6, sel                 ); // and(_pl=player) (rpl=false)
      SetBBit(@_bts1,7, _bts2>0             );

      _wudata_byte(_bts1,rpl);
      if(_bts2>0)then _wudata_byte(_bts2,rpl);
   end;
end;

procedure _wudata(u:integer;rpl:boolean;_pl:byte);
var sh :shortint;
    i  :byte;
begin
   with _units[u] do
   begin
      if(_uvision(_players[_pl].team,u,true))or(rpl)
      then sh:=_hi2S(hits,mhits,_shcf)
      else sh:=-128;

      _wudata_sint(sh,rpl);
      if(sh>-127)then
      begin
         _wudata_byte(uid,rpl);
         _wudata_bstat(u,rpl,_pl);

         if(inapc>0)
         then _wudata_int(inapc,rpl)
         else
         begin
            if(sh>0)then
            begin
               _wudata_int(vx ,rpl);
               _wudata_int(vy ,rpl);
            end
            else
            begin
               _wudata_byte(vx shr 5,rpl);
               _wudata_byte(vy shr 5,rpl);
            end;
         end;

         if(sh>0)then
         begin
            if(uid in whocanattack)and(tar1>0)then _wudata_int(tar1,rpl);
            if(isbuild)and(bld)then
            begin
               if(uid=UID_URadar)then
                if(rpl)or(_players[_pl].team=_players[player].team)then
                begin
                   if(rld<=0)
                   then i:=0
                   else i:=(rld div vid_fps)+1;
                   _wudata_byte(i,rpl);
                   if(i>19)then
                   begin
                      _wudata_int(uo_x ,rpl);
                      _wudata_int(uo_y ,rpl);
                   end;
                end;
               if(uid=UID_URocketL)then
               begin
                  if(rld<=0)
                  then i:=0
                  else i:=rld;
                  _wudata_byte(i,rpl);
                  if(i>0)then
                  begin
                     _wudata_int(uo_x ,rpl);
                     _wudata_int(uo_y ,rpl);
                  end;
               end;
               //
            end;

            if(rpl=false)and(player=_pl)then
            begin
               if(sel)then _wudata_byte(order,rpl);
               if(isbuild)then
               begin
                  if(bld)then
                  begin
                     if(uid in clnet_rld)then
                     begin
                        if(rld<=0)
                        then i:=0
                        else i:=(rld div vid_fps)+1;
                        _wudata_byte(i,rpl);
                     end;
                     if(uid in clnet_utr)then _wudata_byte(utrain,rpl);
                  end;
                  if(sel)then
                   if(uid in whocanmp)then
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

procedure _wpdata(rpl:boolean);
var i,n,u,y:byte;
begin
   _wudata_byte(G_plstat,rpl);
   if(G_plstat>0)then
    for i:=1 to MaxPlayers do
     with _players[i] do
      if((G_plstat and (1 shl i))>0)then
       for n:=0 to _utsh do
       begin
          y:=0;
          u:=n*2;
          if(u<=_uts)then y:=y or  upgr[u];
          inc(u,1);
          if(u<=_uts)then y:=y or (upgr[u] shl 4);
          _wudata_byte(y,rpl);
       end;
end;

procedure _wclinet_gframe(_pl:byte;rpl:boolean);
var    i: byte;
    gstp: cardinal;
    _PNU: pbyte;
    _N_U: pinteger;
begin
   _wudata_card(G_Step,rpl);

   gstp:=G_Step shr 1;
   if((gstp mod vid_hhfps)=0)then
    if(rpl=false)then
     with _players[_pl] do
     begin
        _wudata_byte(bld_r,rpl);
     end;

   if(rpl)
   then i:=vid_fps
   else i:=vid_hfps;

   if((gstp mod i)=0)then
   begin
      _wpdata(rpl);

      if(g_mode=gm_inv)then
      begin
         _wudata_byte(g_inv_wn,rpl);
         _wudata_int (g_inv_t ,rpl);
      end;
      if(g_mode=gm_ct)then
       for i:=1 to MaxPlayers do
        _wudata_byte(g_ct_pl[i].pl,rpl);
   end;

   if(rpl)then
   begin
      _PNU:=@_pnua[_rpls_pnui];
      _N_U:=@_rpls_u;
   end
   else
   begin
      _PNU:=@_players[_pl].PNU;
      _N_U:=@_players[_pl].n_u;
   end;

   _wudata_byte(_PNU^,rpl);
   _wudata_int (_N_U^,rpl);
   for i:=1 to _PNU^ do
   begin
      inc(_N_U^,1);

      if(_N_U^<1)then _N_U^:=1;
      if(_N_U^>MaxUnits)then _N_U^:=1;

      _wudata(_N_U^,rpl,_pl);
   end;
end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

function GetBBit(pb:pbyte;nb:byte):boolean;
begin
   GetBBit:=(pb^ and (1 shl nb))>0;
end;

procedure _ucInc(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin
      inc(uid_e[uid],1);
      inc(u_e[isbuild,ucl],1);
      inc(u_c[isbuild]);
      inc(army,1);

      if(inapc>0)then inc(_units[inapc].apcc,apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then inc(u_s[isbuild,ucl],1);
         if(isbuild)then
          if(bld=false)
          then inc(cenerg,_ulst[cl2uid[race,true,ucl]].renerg)
          else
          begin
             inc(uid_b[uid],1);
             inc(u_eb[isbuild,ucl],1);
             if(ubx[ucl]=0)then ubx[ucl]:=u;
             case ucl of
              0 : inc(bldrs,1);
              1 : if(rld>0)then
                  begin
                     if(_ulst[cl2uid[race,false,utrain]].max=1)then inc(wbhero,1);
                     inc(cenerg,_ulst[cl2uid[race,false,utrain]].renerg);
                     inc(wb,1);
                  end;
              3 : if(rld>0)then
                  begin
                     inc(cenerg,_pne_r[race,utrain]);
                     inc(upgrinp[utrain],1);
                  end;
             end;
          end;
      end;
   end;
end;

procedure _ucDec(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin
      dec(uid_e[uid],1);
      dec(u_e[isbuild,ucl],1);
      dec(u_c[isbuild]);
      dec(army,1);

      if(inapc>0)then dec(_units[inapc].apcc,apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then dec(u_s[isbuild,ucl],1);
         if(isbuild)then
          if(bld=false)
          then dec(cenerg,_ulst[cl2uid[race,true,ucl]].renerg)
          else
          begin
             dec(uid_b[uid],1);
             dec(u_eb[isbuild,ucl],1);
             if(ubx[ucl]=u)then ubx[ucl]:=0;
             case ucl of
              0 : dec(bldrs,1);
              1 : if(rld>0)then
                  begin
                     if(_ulst[cl2uid[race,false,utrain]].max=1)then dec(wbhero,1);
                     dec(cenerg,_ulst[cl2uid[race,false,utrain]].renerg);
                     dec(wb,1);
                  end;
              3 : if(rld>0)then
                  begin
                     dec(cenerg,_pne_r[race,utrain]);
                     dec(upgrinp[utrain],1);
                  end;
             end;
          end;
      end;
   end;
end;

procedure _netClUCreateEff(u:integer;pu:PTUnit);
begin
   with _units[u] do
    with _players[player] do
    begin
       vx:=x;
       vy:=y;

       if(isbuild)then
       begin
          case uid of
          UID_Heye:
             begin
                shadow :=1;
                if(player=HPlayer)then PlaySND(snd_hellbar,0);
                _effect_add(vx,vy,vy+1,UID_LostSoul);
             end;
          UID_HMilitaryUnit:
             begin
                _effect_add(vx,vy,vy+1,UID_HMilitaryUnit);
                PlaySND(snd_hellbar,u);
                shadow :=0;
             end;
          else
             if(player=HPlayer)and(bld=false)then
              if(pu^.bld=true)or(pu^.hits<0)then PlaySND(snd_build[race],0);
             shadow :=0;
          end
       end
       else
         if(buff[ub_born]>0)then
         begin
            if(player=HPlayer)then _unit_createsound(uid);
         end;

       if(buff[ub_teleeff]>0)then
       begin
          _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
          PlaySND(snd_teleport,u);
       end;
    end;
end;

procedure _netSetUcl(u:integer);
var pu:PTUnit;
begin
   pu:=@_units[0];
   with _units[u] do
    with _players[player] do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // d to a
     begin
        _unit_def(u);

        if(inapc>0)then
        begin
           x:=_units[inapc].x;
           y:=_units[inapc].y;
           _unit_sfog(u);
           _unit_mmcoords(u);
        end;

        vx:=x;
        vy:=y;

        if(hits>0)then
        begin
           _unit_fsrclc(@_units[u]);
           _netClUCreateEff(u,pu);
        end;

        _unit_upgr(u);
        _ucInc(u);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // a to d
       begin
          vx:=x;
          vy:=y;
          if(pu^.hits>0)then
           if(hits>ndead_hits)and(inapc=0)then _unit_deff(u,false);

          _unit_upgr(0);
          _ucDec(0);

          x:=-32000;
          y:=-32000;
          vx:=x;
          vy:=y;
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uid<>uid)then
            begin
               _unit_def(u);

               vx:=x;
               vy:=y;

               _netClUCreateEff(u,pu);
            end;

            _unit_upgr(0);
            _ucDec(0);

            _unit_upgr(u);
            _ucInc(u);

            if(hits>0)then
             if(pu^.buff[ub_born]=0)and(buff[ub_born]>0)then _netClUCreateEff(u,pu);

            if(pu^.hits<=0)and(hits>0)then
            begin
               _unit_fsrclc(@_units[u]);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buff[ub_resur]=0)then _unit_deff(u,hits<=idead_hits);

            if(pu^.inapc<>inapc)and(_nhp3(x,y,player))then PlaySND(snd_inapc,0);

            if(pu^.inapc=0)and(inapc>0)then
            begin
               x:=_units[inapc].x;
               y:=_units[inapc].y;
               _unit_sfog(u);
               _unit_mmcoords(u);
            end;

            if(uid=UID_URadar)then
             if(bld)and(pu^.rld=0)and(rld>0)and(team=_players[HPlayer].team)then PlaySND(snd_radar,0);

            if(uid=UID_URocketL)then
             if(bld)and(pu^.rld=0)and(rld>0)then
             begin
                _uac_rocketl_eff(u);
                _miss_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,player,uf_soaring,false);
             end;

            if(pu^.buff[ub_cast]=0)and(buff[ub_cast]>0)then
             case uid of
             UID_ArchVile: PlaySND(snd_meat,u);
             UID_Pain    : _pain_action(u);
             end;

            if(pu^.buff[ub_gear]=0)and(buff[ub_gear]>0)then PlaySND(snd_uupgr,u);

            if(race=r_hell)and(isbuild=false)and(hits>0)then
            begin
               if(pu^.buff[ub_advanced]=0)and(buff[ub_advanced]>0)then _unit_PowerUpEff(u,snd_hupgr );
               if(pu^.buff[ub_invuln  ]=0)and(buff[ub_invuln  ]>0)then _unit_PowerUpEff(u,snd_hpower);

               if(buff[ub_teleeff]=0)then
               if(pu^.buff[ub_pain    ]=0)and(buff[ub_pain    ]>0)then _unit_painsnd(u);
            end;

            if(uid=UID_UCommandCenter)then
            begin
               if(pu^.buff[ub_advanced]=0)and(buff[ub_advanced]>0)then
               begin
                  speed:= 6;
                  uf   := uf_fly;
                  buff[ub_clcast]  := uaccc_fly;
                  PlaySND(snd_ccup,u);
               end;
               if(pu^.buff[ub_advanced]>0)and(buff[ub_advanced]=0)then
               begin
                  speed:= 0;
                  uf   := uf_ground;
                  buff[ub_clcast]  := uaccc_fly;
                  vy:=y;
                  PlaySND(snd_inapc,u);
               end;
               if(buff[ub_advanced]>0)then
               begin
                  speed:=6;
                  uf   := uf_fly;
               end;
            end;

            if(tar1>0)and(tar1<=MaxUnits)then tar1d:=dist2(x,y,_units[tar1].x,_units[tar1].y);

            if(speed>0)then
            begin
               uo_x:=pu^.x;
               uo_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               _unit_sfog(u);
               _unit_mmcoords(u);

               if(pu^.buff[ub_teleeff]=0)and(buff[ub_teleeff]>0)then
                if(uid=UID_HKeep)then
                begin
                   if(_nhp3(x,y,player)or _nhp3(pu^.x,pu^.y,player))then PlaySND(snd_cubes,0);
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
                   if(_nhp3(vx,vy,player)or _nhp3(pu^.vx,pu^.vy,player))then PlaySND(snd_teleport,0);
                   _effect_add(vx    ,vy    ,    vy+map_flydpth[uf]+1,EID_Teleport);
                   _effect_add(pu^.vx,pu^.vy,pu^.vy+map_flydpth[uf]+1,EID_Teleport);
                end;

               if(speed>0)then
               begin
                  vstp:=UnitStepNum;

                  dir:=p_dir(uo_x,uo_y,x,y);
               end;
            end;
         end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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


procedure _rudata_bstat(u:integer;rpl:boolean);
var _bts1,
    _bts2:byte;
begin
   with _units[u] do
   begin
      _bts1:=_rudata_byte(rpl,0);

      bld:=GetBBit(@_bts1,0);
      if(GetBBit(@_bts1,1))then inapc:=1 else inapc:=0;
      buff[ub_advanced ]:=_buffst[GetBBit(@_bts1,2)];
      buff[ub_pain     ]:=_buffst[GetBBit(@_bts1,3)];
      buff[ub_cast     ]:=_buffst[GetBBit(@_bts1,4)];
      if(GetBBit(@_bts1,5))then tar1:=-1 else tar1:=0;
      sel:=GetBBit(@_bts1,6);
      if(GetBBit(@_bts1,7))
      then _bts2:=_rudata_byte(rpl,0)
      else _bts2:=0;

      if(_bts2>0)then
      begin
         buff[ub_toxin    ]:=_buffst[GetBBit(@_bts2,0)];
         buff[ub_gear     ]:=_buffst[GetBBit(@_bts2,1)];
         buff[ub_resur    ]:=_buffst[GetBBit(@_bts2,2)];
         buff[ub_born     ]:=_buffst[GetBBit(@_bts2,3)];
         buff[ub_invuln   ]:=_buffst[GetBBit(@_bts2,4)];
         buff[ub_teleeff  ]:=_buffst[GetBBit(@_bts2,5)];
      end
      else
      begin
         buff[ub_toxin    ]:=0;
         buff[ub_gear     ]:=0;
         buff[ub_resur    ]:=0;
         buff[ub_born     ]:=0;
         buff[ub_invuln   ]:=0;
         buff[ub_teleeff  ]:=0;
      end;

      if(rpl=false)then _addtoint(@vsnt[_players[HPlayer].team],vistime);
   end;
end;

procedure _rudata(u:integer;rpl:boolean;_pl:byte);
var sh:shortint;
    i :byte;
begin
   _units[0]:=_units[u];
   with _units[u] do
   begin
      player:=(u-1) div MaxPlayerUnits;
      sh:=_rudata_sint(rpl,-128);
      if(sh>-127)then
      begin
         i   :=uid;
         uid :=_rudata_byte(rpl,0);
         if(i<>uid)then
         begin
            _unit_sclass(@_units[u]);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_S2hi(sh,mhits,_shcf);
         _rudata_bstat(u,rpl);

         if(inapc>0)
         then inapc:=_rudata_int(rpl,0)
         else
         begin
            if(sh>0)then
            begin
               x:=_rudata_int(rpl,x);
               y:=_rudata_int(rpl,y);
            end
            else
            begin
               x:=integer(_rudata_byte(rpl,x) shl 5)+(x mod 32);
               y:=integer(_rudata_byte(rpl,x) shl 5)+(y mod 32);
            end;
         end;

         if(sh>0)then
         begin
            if(tar1=-1)then tar1:=_rudata_int(rpl,0);
            if(isbuild)and(bld)then
            begin
               if(uid=UID_URadar)then
                if(rpl)or(_players[_pl].team=_players[player].team)then
                begin
                   i  :=_rudata_byte(rpl,0);
                   if(i=0)
                   then rld:=0
                   else rld:=i*vid_fps-1;
                   if(i>19)then
                   begin
                      uo_x:=_rudata_int(rpl,-1000);
                      uo_y:=_rudata_int(rpl,-1000);
                   end;
                end;
               if(uid=UID_URocketL)then
               begin
                  if(rld=0)then
                  begin
                     rld :=_rudata_byte(rpl,0);
                     if(rld>0)then
                     begin
                        uo_x:=_rudata_int(rpl,0);
                        uo_y:=_rudata_int(rpl,0);
                     end;
                  end
                  else
                  begin
                     rld_a:=_rudata_byte(rpl,0);
                     if(rld_a>0)then
                     begin
                        _rudata_int(rpl,0);
                        _rudata_int(rpl,0);
                     end;
                  end;
               end;
            end;

            if(rpl=false)and(player=HPlayer)then
            begin
               if(sel)then order:=_rudata_byte(rpl,0);
               if(isbuild)then
               begin
                  if(bld)then
                  begin
                     if(uid in clnet_rld)then
                     begin
                        i  :=_rudata_byte(rpl,0);
                        if(i=0)
                        then rld:=0
                        else rld:=i*vid_fps-1;
                     end;
                     if(uid in clnet_utr)then utrain:=_rudata_byte(rpl,0);
                  end;
                  if(sel)then
                   if(uid in whocanmp)then
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
   _netSetUcl(u);
end;

procedure _rpdata(rpl:boolean);
var i,o,u,y:byte;
begin
   G_plstat:=_rudata_byte(rpl,0);

   if(G_plstat>0)then
    for i:=1 to MaxPlayers do
     if((G_plstat and (1 shl i))>0)then
      with _players[i] do
       for o:=0 to _utsh do
       begin
          y:=_rudata_byte(rpl,0);
          u:=o*2;
          if(u<=_uts)then upgr[u]:= y and %00001111;
          inc(u,1);
          if(u<=_uts)then upgr[u]:= y shr 4;
       end;
end;

procedure _rclinet_gframe(_pl:byte;rpl:boolean);
var gstp: cardinal;
    _PNU,
    i   : byte;
    _N_U: integer;
begin
   G_Step:=_rudata_card(rpl,G_Step);

   gstp:=G_Step shr 1;
   if((gstp mod vid_hhfps)=0)then
    if(rpl=false)then
     with _players[_pl] do
     begin
        bld_r:=_rudata_byte(rpl,0);
     end;

   if(rpl)
   then i:=vid_fps
   else i:=vid_hfps;

   if((gstp mod i)=0)then
   begin
      _rpdata(rpl);

      if(g_mode=gm_inv)then
      begin
         _PNU:=g_inv_wn;
         g_inv_wn:=_rudata_byte(rpl,0);
         if(g_inv_wn>_PNU)then PlaySND(snd_teleport,0);
         g_inv_t :=_rudata_int (rpl,0);
      end;
      if(g_mode=gm_ct)then
       for i:=1 to MaxPlayers do
        g_ct_pl[i].pl:=_rudata_byte(rpl,0);
   end;

   _PNU:=_rudata_byte(rpl,0);

   if(_PNU<>_rpls_pnu)then
   begin
      _rpls_pnu:=_PNU;
      if(_rpls_pnu=0)then _rpls_pnu:=1;
      UnitStepNum:=trunc(MaxUnits/_rpls_pnu)*NetTickN;
      if(UnitStepNum=0)then UnitStepNum:=1;
   end;

   _N_U:=_rudata_int (rpl,0);
   for i:=1 to _PNU do
   begin
      inc(_N_U,1);

      if(_N_U<1       )then _N_U:=1;
      if(_N_U>MaxUnits)then _N_U:=1;

      _rudata(_N_U,rpl,_pl);
   end;
   for i:=0 to MaxPlayers do
    with _players[i] do
    begin
       menerg:=0;
       inc(menerg,u_eb[true,0]*builder_enrg[upgr[upgr_bldenrg]]);
       inc(menerg,u_eb[true,2]*_ulst[cl2uid[race,true,2]].generg);
       if(G_startb=4)then inc(menerg,100);
    end;
end;
{$ENDIF}


