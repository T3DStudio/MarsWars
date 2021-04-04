
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
      //SetBBit(@_bts1,5, (uidi in whocanattack)and(tar1>0)); attack
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
            //if(uidi in whocanattack)and(a_tar1>0)then _wudata_int(tar1,rpl);

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then _wudata_byte(order,rpl);
               if(_isbuilding)then
               begin
                  if(bld)then
                  begin
                     if(_ability in clint_rld_abils)then _wrld(@rld,rpl);
                     _wprod(pu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(pu))then
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
     with _players[_pl] do _wudata_byte(bld_r,rpl);

   if(rpl)
   then i:=fr_fps
   else i:=fr_hfps;

   if((gstp mod i)=0)then
    case g_mode of
gm_inv:begin
          _wudata_byte(g_inv_wn,rpl);
          _wudata_int (g_inv_t ,rpl);
       end;
gm_ct :for i:=1 to MaxCPoints do _wudata_byte(g_cpt_pl[i].pl,rpl);
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

      if(inapc>0)then inc(_units[inapc].apcc,_apcs);

      if(hits>0)and(inapc=0)then
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

      if(inapc>0)then dec(_units[inapc].apcc,_apcs);

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

{procedure _netClUCreateEff(pu,tu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       vx:=x;
       vy:=y;

       if(isbuild)then
       begin
          case uidi of
          UID_Heye:
             begin
                shadow :=1;
                if(playeri=HPlayer)then PlaySND(snd_hellbar,nil);
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
             if(playeri=HPlayer)and(bld=false)then
              if(tu^.bld=true)or(tu^.hits<0)then PlaySND(snd_build[race],nil);
             shadow :=0;
          end
       end
       else
         if(buff[ub_born]>0)then
         begin
            if(playeri=HPlayer)then _unit_createsound(uidi);
         end;

       if(buff[ub_teleeff]>0)then
       begin
          _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
          PlaySND(snd_teleport,pu);
       end;
    end;
end;  }

procedure _netSetUcl(uu:PTUnit);
var pu:PTUnit;
begin
   pu:=@_units[0];
   with uu^ do
    with player^ do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // not exists to exists
     begin
        _unit_default(uu);

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
           _unit_fog_r(uu);
          // _netClUCreateEff(uu,pu);
        end;

        _unit_upgr(uu);
        _ucInc(uu);
     end
     else
       if(pu^.hits>dead_hits)and(hits<=dead_hits)then // exists to not exists
       begin
          vx:=x;
          vy:=y;
          //if(pu^.hits>0)then
          // if(hits>ndead_hits)and(inapc=0)then _unit_deff(uu,false);

          _unit_upgr(pu);
          _ucDec(pu);

          x :=-32000;
          y :=-32000;
          vx:=x;
          vy:=y;
       end
       else
         if(pu^.hits>dead_hits)and(hits>dead_hits)then
         begin
            if(pu^.uidi<>uidi)then
            begin
               _unit_default(uu);

               vx:=x;
               vy:=y;

               //_netClUCreateEff(uu,pu);
            end;

            _unit_upgr(pu);
            _ucDec(pu);

            _unit_upgr(uu);
            _ucInc(uu);

            //if(hits>0)then
            // if(pu^.buff[ub_born]=0)and(buff[ub_born]>0)then _netClUCreateEff(uu,pu);

            if(pu^.hits<=0)and(hits>0)then
            begin
               _unit_fog_r(uu);
               vx:=x;
               vy:=y;
            end
            else
              if(pu^.hits>0)and(hits<=0)and(buff[ub_resur]=0)then
              begin
                 //_unit_deff(uu,hits<=idead_hits);
                 rld:=0;
              end;

            //if(pu^.inapc<>inapc)and(_nhp3(x,y,player))then PlaySND(snd_inapc,nil);

            if(pu^.inapc=0)and(inapc>0)then
            begin
               x:=_units[inapc].x;
               y:=_units[inapc].y;
               _unit_sfog(uu);
               _unit_mmcoords(uu);
            end;

            {if(uidi=UID_URadar)then
             if(bld)and(pu^.rld_t=0)and(rld_t>0)and(team=_players[HPlayer].team)then PlaySND(snd_radar,nil);

            if(uidi=UID_URocketL)then
             if(bld)and(pu^.rld_t=0)and(rld_t>0)then
             begin
                _uac_rocketl_eff(uu);
                _miss_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playeri,uf_soaring,false);
             end;

            if(pu^.buff[ub_cast]=0)and(buff[ub_cast]>0)then
             case uidi of
             UID_ArchVile: ;
             UID_Pain    : _pain_action(uu);
             end;

            if(uidi in [UID_Major,UID_ZMajor])then
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

            if(tar1>0)and(tar1<=MaxUnits)then tar1d:=dist2(x,y,_units[tar1].x,_units[tar1].y);    }

            if(speed>0)then
            begin
               uo_x:=pu^.x;
               uo_y:=pu^.y;
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

                  dir :=p_dir(uo_x,uo_y,x,y);
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
     // if(GetBBit(@_bts1,5))then tar1:=-1 else tar1:=0;
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
            FillChar(buff,SizeOf(buff),0);
         end;
         hits:=_S2hi(sh,uid^._mhits,uid^._shcf);
         _rudata_bstat(uu,rpl);

         if(inapc>0)
         then inapc:=mm3(0,_rudata_int(rpl,0),MaxUnits)
         else
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

         if(sh>0)then
         begin
           // if(tar1=-1)then tar1:=max2(0,min2(MaxUnits,_rudata_int(rpl,0)));

            if(rpl=false)and(playeri=_pl)then
            begin
               if(sel)then order:=_rudata_byte(rpl,0);
               if(uid^._isbuilding)then
               begin
                  if(bld)then
                  begin
                     if(uid^._ability in clint_rld_abils)then _rrld(@rld,rpl);
                     _rprod(uu,rpl);
                  end;
                  if(sel)and(_UnitHaveRPoint(uu))then
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
var i,n,bp,bv:byte;
begin
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
   if((gstp mod fr_hhfps)=0)then
    if(rpl=false)then
     with _players[_pl] do
     begin
        bld_r:=_rudata_byte(rpl,0);
     end;

   if(rpl)
   then i:=fr_fps
   else i:=fr_hfps;

   if((gstp mod i)=0)then
    case g_mode of
gm_inv:begin
          _PNU:=g_inv_wn;
          g_inv_wn:=_rudata_byte(rpl,0);
          if(g_inv_wn>_PNU)then PlaySND(snd_teleport,nil);
          g_inv_t :=_rudata_int (rpl,0);
       end;
gm_ct: for i:=1 to MaxCPoints do g_cpt_pl[i].pl:=_rudata_byte(rpl,0);
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
         UnitStepNum:=trunc(MaxUnits/_rpls_pnu)*NetTickN+2;
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


