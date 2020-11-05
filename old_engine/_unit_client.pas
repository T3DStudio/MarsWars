
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

procedure _wudata_bstat(pu:PTUnit;rpl:boolean;_pl:byte);
var _bts1,
    _bts2:byte;
begin
   with pu^ do
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
   else _wrld:=(r^ div vid_fps)+1;
   _wudata_byte(_wrld,rpl);
end;

procedure _wprod(pu:PTUnit;rpl:boolean);
var i: byte;
begin
   with pu^ do
    for i:=0 to MaxUnitProds do
     case ucl of
     1: if(_wrld(@uprod_r[i],rpl)>0)then _wudata_byte(uprod_t[i],rpl);
     3: if(_wrld(@pprod_r[i],rpl)>0)then _wudata_byte(pprod_t[i],rpl);
     end;
end;

procedure _wudata(pu:PTUnit;rpl:boolean;_pl:byte);
var sh :shortint;
begin
   with pu^ do
   begin
      if(_uvision(_players[_pl].team,pu,true))or(rpl)
      then sh:=_hi2S(hits,mhits,_shcf)
      else sh:=-128;

      _wudata_sint(sh,rpl);
      if(sh>-127)then
      begin
         _wudata_byte (uid,rpl);
         _wudata_bstat(pu,rpl,_pl);

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
             case uid of
               UID_URadar:
                  if(rpl)or(_players[_pl].team=_players[playern].team)then
                  begin
                     if(_wrld(@rld_t,rpl)>19)then
                     begin
                        _wudata_int(uo_x ,rpl);
                        _wudata_int(uo_y ,rpl);
                     end;
                  end;
               UID_URocketL:
                  begin
                     if(_wrld(@rld_t,rpl)>0)then
                     begin
                        _wudata_int(uo_x ,rpl);
                        _wudata_int(uo_y ,rpl);
                     end;
                  end;
             end;

            if(rpl=false)and(playern=_pl)then
            begin
               if(sel)then _wudata_byte(order,rpl);
               if(isbuild)then
               begin
                  if(bld)then
                  begin
                     if(uid in clnet_rld )then _wrld(@rld_t,rpl);
                     if(isbarrack)or(issmith)then _wprod(pu,rpl);
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

      _wudata(@_units[_N_U^],rpl,_pl);
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
begin
   with pu^ do
   with _players[playern] do
   begin
      inc(uid_e[uid],1);
      inc(ucl_e[isbuild,ucl],1);
      inc(ucl_c[isbuild]);
      inc(army,1);

      if(inapc>0)then inc(_units[inapc].apcc,apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then _unit_inc_selc(pu);
         if(isbuild)then
          if(bld=false)
          then inc(cenerg,_ulst[cl2uid[race,true,ucl]].renerg)
          else
          begin
             inc(uid_eb[uid],1);
             inc(ucl_eb[isbuild,ucl],1);
             if(ucl_x[ucl]=0)then ucl_x[ucl]:=unum;
             if(0<ucl_x[ucl])and(ucl_x[ucl]<=MaxUnits)then
              if(_units[ucl_x[ucl]].ucl<>ucl)then ucl_x[ucl]:=unum;
             if(uid_x[uid]=0)then uid_x[uid]:=unum;

             _unit_done_inc_cntrs(pu);

             if(isbarrack)then
              for i:=0 to MaxUnitProds do
               if(uprod_r[i]>0)then
               begin
                  _puid:=cl2uid[race,false,uprod_t[i]];

                  inc(uproda,1);
                  inc(uprodc[uprod_t[i]],1);
                  inc(uprodu[_puid],1);
                  inc(cenerg,_ulst[_puid].renerg);
               end;
             if(issmith)then
              for i:=0 to MaxUnitProds do
               if(pprod_r[i]>0)then
               begin
                  inc(pproda,1);
                  inc(cenerg,_pne_r[race,pprod_t[i] ]);
                  inc(upgrinp[ pprod_t[i] ],1);
               end;
          end;
      end;
   end;
end;

procedure _ucDec(pu:PTUnit);
var i,_puid:byte;
begin
   with pu^ do
   with _players[playern] do
   begin
      dec(uid_e[uid],1);
      dec(ucl_e[isbuild,ucl],1);
      dec(ucl_c[isbuild]);
      dec(army,1);

      if(inapc>0)then dec(_units[inapc].apcc,apcs);

      if(hits>0)and(inapc=0)then
      begin
         if(sel)then _unit_dec_selc(pu);
         if(isbuild)then
          if(bld=false)
          then dec(cenerg,_ulst[cl2uid[race,true,ucl]].renerg)
          else
          begin
             dec(uid_eb[uid],1);
             dec(ucl_eb[isbuild,ucl],1);
             if(ucl_x[ucl]=unum)then ucl_x[ucl]:=0;
             if(uid_x[uid]=unum)then uid_x[uid]:=0;

             _unit_done_dec_cntrs(pu);

             if(isbarrack)then
              for i:=0 to MaxUnitProds do
               if(uprod_r[i]>0)then
               begin
                  _puid:=cl2uid[race,false,uprod_t[i]];

                  dec(uproda,1);
                  dec(uprodc[uprod_t[i]],1);
                  dec(uprodu[_puid],1);
                  dec(cenerg,_ulst[_puid].renerg);
               end;
             if(issmith)then
              for i:=0 to MaxUnitProds do
               if(pprod_r[i]>0)then
               begin
                  dec(pproda,1);
                  dec(cenerg,_pne_r[race,pprod_t[i] ]);
                  dec(upgrinp[ pprod_t[i] ],1);
               end;
          end;
      end;
   end;
end;

procedure _netClUCreateEff(pu,tu:PTUnit);
begin
   with pu^ do
    with _players[playern] do
    begin
       vx:=x;
       vy:=y;

       if(isbuild)then
       begin
          case uid of
          UID_Heye:
             begin
                shadow :=1;
                if(playern=HPlayer)then PlaySND(snd_hellbar,nil);
                _effect_add(vx,vy,vy+1,UID_LostSoul);
             end;
          UID_HMilitaryUnit:
             begin
                if(buff[ub_advanced]>0)
                then _effect_add(vx,vy,vy+1,EID_HAMU)
                else _effect_add(vx,vy,vy+1,EID_HMU);
                PlaySND(snd_hellbar,pu);
                shadow :=0;
             end;
          UID_HCommandCenter:
             begin
                _effect_add(vx,vy,vy+1,EID_HCC);
                PlaySND(snd_hellbar,pu);
                shadow :=0;
             end;
          else
             if(playern=HPlayer)and(bld=false)then
              if(tu^.bld=true)or(tu^.hits<0)then PlaySND(snd_build[race],nil);
             shadow :=0;
          end
       end
       else
         if(buff[ub_born]>0)then
         begin
            if(playern=HPlayer)then _unit_createsound(uid);
         end;

       if(buff[ub_teleeff]>0)then
       begin
          _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
          PlaySND(snd_teleport,pu);
       end;
    end;
end;

procedure _netSetUcl(uu:PTUnit);
var pu:PTUnit;
begin
   pu:=@_units[0];
   with uu^ do
    with _players[playern] do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // d to a
     begin
        _unit_def(uu);

        if(inapc>0)then
        begin
           x:=_units[inapc].x;
           y:=_units[inapc].y;
           _unit_sfog(uu);
           _unit_mmcoords(uu);
        end;

        vx:=x;
        vy:=y;

        if(hits>0)then
        begin
           _unit_fsrclc(uu);
           _netClUCreateEff(uu,pu);
        end;

        _unit_upgr(uu);
        _ucInc(uu);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // a to d
       begin
          vx:=x;
          vy:=y;
          if(pu^.hits>0)then
           if(hits>ndead_hits)and(inapc=0)then _unit_deff(uu,false);

          _unit_upgr(pu);
          _ucDec(pu);

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
               _unit_def(uu);

               vx:=x;
               vy:=y;

               _netClUCreateEff(uu,pu);
            end;

            _unit_upgr(pu);
            _ucDec(pu);

            _unit_upgr(uu);
            _ucInc(uu);

            if(hits>0)then
             if(pu^.buff[ub_born]=0)and(buff[ub_born]>0)then _netClUCreateEff(uu,pu);

            if(pu^.hits<=0)and(hits>0)then
            begin
               _unit_fsrclc(uu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buff[ub_resur]=0)then
              begin
                 _unit_deff(uu,hits<=idead_hits);
                 rld_t:=0;
              end;

            if(pu^.inapc<>inapc)and(_nhp3(x,y,playern))then PlaySND(snd_inapc,nil);

            if(pu^.inapc=0)and(inapc>0)then
            begin
               x:=_units[inapc].x;
               y:=_units[inapc].y;
               _unit_sfog(uu);
               _unit_mmcoords(uu);
            end;

            if(uid=UID_URadar)then
             if(bld)and(pu^.rld_t=0)and(rld_t>0)and(team=_players[HPlayer].team)then PlaySND(snd_radar,nil);

            if(uid=UID_URocketL)then
             if(bld)and(pu^.rld_t=0)and(rld_t>0)then
             begin
                _uac_rocketl_eff(uu);
                _miss_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playern,uf_soaring,false);
             end;

            if(pu^.buff[ub_cast]=0)and(buff[ub_cast]>0)then
             case uid of
             UID_ArchVile: ;
             UID_Pain    : _pain_action(uu);
             end;

            if(uid in [UID_Major,UID_ZMajor])then
             if(buff[ub_advanced]>0)and(hits>0)and(pu^.hits>0)then
             begin
                if(pu^.uf=uf_ground)and(uf>uf_ground)then PlaySND(snd_jetpon ,uu);
                if(pu^.uf>uf_ground)and(uf=uf_ground)then PlaySND(snd_jetpoff,uu);
             end;

            if(pu^.buff[ub_gear ]=0)and(buff[ub_gear ]>0)then PlaySND(snd_uupgr,uu);
            if(pu^.buff[ub_resur]=0)and(buff[ub_resur]>0)then PlaySND(snd_meat ,uu);

            if(race=r_hell)and(isbuild=false)and(hits>0)then
            begin
               if(pu^.buff[ub_advanced]=0)and(buff[ub_advanced]>0)then _unit_PowerUpEff(uu,snd_hupgr );
               if(pu^.buff[ub_invuln  ]=0)and(buff[ub_invuln  ]>0)then _unit_PowerUpEff(uu,snd_hpower);

               if(buff[ub_teleeff]=0)then
               if(pu^.buff[ub_pain    ]=0)and(buff[ub_pain    ]>0)then _unit_painsnd(uu);
            end;

            if(uid in [UID_UCommandCenter,UID_HCommandCenter])then
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

            if(tar1>0)and(tar1<=MaxUnits)then tar1d:=dist2(x,y,_units[tar1].x,_units[tar1].y);

            if(speed>0)then
            begin
               uo_x:=pu^.x;
               uo_y:=pu^.y;
            end;

            if(pu^.x<>x)or(pu^.y<>y)then
            begin
               _unit_sfog(uu);
               _unit_mmcoords(uu);

               if(pu^.buff[ub_teleeff]=0)and(buff[ub_teleeff]>0)then
                if(uid=UID_HKeep)then
                begin
                   if(_nhp3(x,y,playern))
                   or(_nhp3(pu^.x,pu^.y,playern))then PlaySND(snd_cubes,nil);
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
                   if(_nhp3(vx,vy,playern))
                   or(_nhp3(pu^.vx,pu^.vy,playern))then PlaySND(snd_teleport,nil);
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

function _rrld(r:pinteger;rpl:boolean):byte;
begin
   _rrld  :=_rudata_byte(rpl,0);
   if(_rrld=0)
   then r^:=0
   else r^:=_rrld*vid_fps-1;
end;

procedure _rprod(uu:PTUnit;rpl:boolean);
var i: byte;
begin
   with uu^ do
    for i:=0 to MaxUnitProds do
     case ucl of
     1: if(_rrld(@uprod_r[i],rpl)>0)then uprod_t[i]:=_rudata_byte(rpl,0);
     3: if(_rrld(@pprod_r[i],rpl)>0)then pprod_t[i]:=_rudata_byte(rpl,0);
     end;
end;

procedure _rudata(uu:PTUnit;rpl:boolean;_pl:byte);
var sh:shortint;
    i :byte;
begin
   _units[0]:=uu^;
   with uu^ do
   begin
      playern:=(unum-1) div MaxPlayerUnits;
      sh:=_rudata_sint(rpl,-128);
      if(sh>-127)then
      begin
         i   :=uid;
         uid :=_rudata_byte(rpl,0);
         if(i<>uid)then
         begin
            _unit_sclass(uu);
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_S2hi(sh,mhits,_shcf);
         _rudata_bstat(uu,rpl);

         if(inapc>0)
         then inapc:=max2(0,min2(MaxUnits,_rudata_int(rpl,0)))
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
            if(tar1=-1)then tar1:=max2(0,min2(MaxUnits,_rudata_int(rpl,0)));
            if(isbuild)and(bld)then
             case uid of
              UID_URadar:
                if(rpl)or(_players[_pl].team=_players[playern].team)then
                begin
                   if(_rrld(@rld_t,rpl)>19)then
                   begin
                      uo_x:=_rudata_int(rpl,-1000);
                      uo_y:=_rudata_int(rpl,-1000);
                   end;
                end;
              UID_URocketL:
                begin
                   if(_rrld(@rld_t,rpl)>0)then
                   begin
                      uo_x:=_rudata_int(rpl,0);
                      uo_y:=_rudata_int(rpl,0);
                   end;
                end;
             end;

            if(rpl=false)and(playern=HPlayer)then
            begin
               if(sel)then order:=_rudata_byte(rpl,0);
               if(isbuild)then
               begin
                  if(bld)then
                  begin
                     if(uid in clnet_rld )then _rrld(@rld_t,rpl);
                     if(isbarrack)or(issmith)then _rprod(uu,rpl);
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
   _netSetUcl(uu);
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
         if(g_inv_wn>_PNU)then PlaySND(snd_teleport,nil);
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
      UnitStepNum:=trunc(MaxUnits/_rpls_pnu)*NetTickN+2;
      if(UnitStepNum=0)then UnitStepNum:=1;
   end;

   _N_U:=_rudata_int (rpl,0);
   for i:=1 to _PNU do
   begin
      inc(_N_U,1);

      if(_N_U<1       )then _N_U:=1;
      if(_N_U>MaxUnits)then _N_U:=1;

      _units[_N_U].unum:=_N_U;
      _rudata(@_units[_N_U],rpl,_pl);
   end;
   for i:=0 to MaxPlayers do
    with _players[i] do
    begin
       menerg:=0;
       inc(menerg,ucl_eb[true,0]*builder_enrg[upgr[upgr_bldenrg]]);
       inc(menerg,ucl_eb[true,2]*_ulst[cl2uid[race,true,2]].generg);
       if(G_startb=5)then inc(menerg,100);
    end;
end;
{$ENDIF}


