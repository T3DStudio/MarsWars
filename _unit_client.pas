


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////// SERVER
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

////////////////////////////////////////////////////////////////////////////////

procedure _wudata_bstat(pu:PTUnit;rpl:boolean);
var _bts1,
    _bts2,
    _vsn,
    _dvsn:byte;
begin
   with (pu^) do
   with (puid^) do
   begin
      _vsn:=0;
      for _dvsn:=0 to MaxPlayers do SetBBit(@_vsn,_dvsn,(vsnt[_dvsn]>0));
      _dvsn:=0;
      SetBBit(@_dvsn,0,true);
      SetBBit(@_dvsn,_players[player].team,true);

      _bts1:=0;
      _bts2:=0;

      SetBBit(@_bts1,0, _vsn<>_dvsn         );
      SetBBit(@_bts1,1, bld                 );
      SetBBit(@_bts1,2, inapc>0             );
      SetBBit(@_bts1,3, buff[ub_advanced ]>0);

      if(inapc=0)then
       if(hits>0)then
       begin
          SetBBit(@_bts2,0, buff[ub_teleff   ]>0);
          SetBBit(@_bts2,1, buff[ub_invuln   ]>0);
          SetBBit(@_bts2,2, buff[ub_born     ]>0);
          SetBBit(@_bts2,3, buff[ub_cast     ]>0);

          SetBBit(@_bts1,4, buff[ub_invis    ]>0);
          SetBBit(@_bts1,5, buff[ub_pain     ]>0);

          SetBBit(@_bts1,7,_bts2>0);
       end
       else SetBBit(@_bts1,4, buff[ub_resur  ]>0);

      _wudata_byte(_bts1,rpl);
      if(_bts2>0)then _wudata_byte(_bts2,rpl);

      if(_vsn<>_dvsn)then _wudata_byte(_vsn,rpl);

      if(GetBBit(@_bts1,2)=false)and(GetBBit(@_bts1,4))and(hits>0)then
      begin
         _vsn:=0;
         for _dvsn:=0 to MaxPlayers do SetBBit(@_vsn,_dvsn,(vsni[_dvsn]>0));
         _wudata_byte(_vsn,rpl);
      end;
   end;
end;

function _wudata_uordl(pu:PTUnit;jcount,rpl:boolean):byte;
var i,p:byte;
begin
   _wudata_uordl:=0;
   with(pu^)do
   begin
      if(sel)
      then p:=0
      else p:=2;
      for i:=0 to uo_n do
      begin
         case p of
         1 : if not(uo_id[i] in [uo_patrol,uo_spatrol])then continue;
         2 : if(uo_id[i]<>uo_prod)then continue;
         end;

         if(jcount)
         then inc(_wudata_uordl,1)
         else
         begin
            _wudata_byte(uo_id[i],rpl);
            if((_toids[uo_id[i]].rtar and at_unit)>0)or(uo_id[i]=uo_prod)then _wudata_int (uo_tar[i],rpl);
            if((_toids[uo_id[i]].rtar and at_map)>0)then
            begin
               _wudata_int (uo_x  [i],rpl);
               _wudata_int (uo_y  [i],rpl);
            end;
         end;

         if(uo_id[i] in [uo_hold  ,uo_destroy])then break;
         if(uo_id[i] in [uo_spatrol,uo_patrol])then p:=1;
      end;
   end;
end;

procedure _wudata(pu:PTUnit;rpl:boolean;_pl:byte);
var sh    :shortint;
    i,
    _bts1,
    _bts2 :byte;
begin
   if(rpl)then _pl:=0;
   with (pu^) do
   with (puid^) do
   begin
      if(_uvision(_players[_pl].team,pu,true))
      then sh:=_hi2S(hits,_mhits,_shcf)
      else sh:=-128;

      _wudata_sint(sh,rpl);
      if(sh>-127)then
      begin
         _wudata_byte(uid,rpl);
         _wudata_bstat(pu,rpl);

         if(inapc>0)
         then _wudata_int(inapc,rpl)
         else
         begin
            if(sh>0)then
            begin
               _wudata_int(x ,rpl);
               _wudata_int(y ,rpl);
            end
            else
            begin
               _wudata_byte(x shr 5,rpl);
               _wudata_byte(y shr 5,rpl);
            end;
         end;

         if(hits>0)then
         begin
            _bts1:=0;
            _bts2:=0;

            if(a_rld>0)
            then _bts1:=a_weap and %00000011
            else _bts1:=%00000011;

            if(player=_pl)and(inapc=0)then
            begin
               i:=_wudata_uordl(pu,true,rpl);

               SetBBit(@_bts1,2,sel);
               if(_itbarrack)and(un_r>0)then SetBBit(@_bts1,3,true);
               if(_itsmith  )and(up_r>0)then SetBBit(@_bts1,4,true);
               SetBBit(@_bts1,5,order>0);
               SetBBit(@_bts1,6,(i>0));
               _wudata_byte(_bts1,rpl);

               if(GetBBit(@_bts1,3))then
               begin
                  _wudata_byte(un_t,rpl);
                  _wudata_int (un_r,rpl);
               end;
               if(GetBBit(@_bts1,4))then
               begin
                  _wudata_byte(up_t,rpl);
                  _wudata_int (up_r,rpl);
               end;
               if(GetBBit(@_bts1,5))then _wudata_byte(order,rpl);

               if(sel)then
               begin
                  if(uo_rallpos in _orders)then
                   if(un_rtar>0)and(un_rtar<=MaxUnits)
                   then _wudata_int(un_rtar,rpl)
                   else
                   begin
                      _wudata_int (MaxUnits+un_rx,rpl);
                      _wudata_int (un_ry,rpl);
                   end;
                  _bts2:=aorder;
                  if(aattack)then _bts2:=_bts2+%10000000;
                  _wudata_byte(_bts2,rpl);
               end;
               if(GetBBit(@_bts1,6))then
               begin
                  _wudata_byte(i-1,rpl);
                  _wudata_uordl(pu,false,rpl);
               end;
            end
            else _wudata_byte(_bts1,rpl);

            if(a_rld>0)then
            begin
               if((_a_weap[a_weap].aw_req and wpr_netst)>0)
               then _wudata_int(ca_tar,rpl)
               else
               begin
                  _wudata_sint(ca_x,rpl);
                  _wudata_sint(ca_y,rpl);
               end;
            end;
         end;
      end;
   end;
end;

procedure _wupgrades(pp:byte;rpl:boolean);
var i,p,
    b,v:byte;
    w  :boolean;
begin
   for p:=1 to MaxPlayers do
    if((pp and (1 shl p))>0)then
     with _players[p] do
     begin
        v:=0;
        b:=0;
        w:=false;
        for i:=1 to 255 do
         with _tupids[i] do
          if(_urace=race)or(_urace=255)then
          begin
             if((b mod 2)=0)then
             begin
                v:=upgr[i];
                w:=true;
             end
             else
             begin
                v:=v or (upgr[i] shl 4);
                _wudata_byte(v,rpl);
                w:=false;
             end;
             inc(b,1);
          end;
        if(w)then _wudata_byte(v,rpl);
     end;
end;

procedure _wclinet_gframe(_pl:byte;rpl:boolean);
var  pp  : byte;
   i,_PNU,
   ucount: integer;
    gstp : cardinal;
    puint: pinteger;
begin
   _wudata_card(G_Step,rpl);

   ucount:=0;
   pp  :=0;
   for i:=1 to MaxPlayers do
    if(_players[i].army>0)then
    begin
       pp  :=pp or (1 shl i);
       inc(ucount,MaxPlayerUnits);
    end;

   if(rpl=false)
   then puint:=@_players[_pl].n_u
   else {$IFDEF _FULLGAME} puint:=@_rpls_u; {$ELSE} exit; {$ENDIF}

   _PNU:=0;
   _wudata_byte(pp,rpl);
   if(pp>0)then
   begin
      if(rpl=false)then _PNU:=_players[_pl].PNU{$IFDEF _FULLGAME}else _PNU:=_cl_pnua[_rpls_pnui];{$ELSE};{$ENDIF}

      _wudata_byte(_PNU,rpl);
      _PNU:=_PNU*3;
      if(_PNU>ucount)then _PNU:=ucount;

      if(rpl=false)then _wudata_byte(_players[_pl]._lsuc,rpl);

      gstp:=G_Step shr 1;
      if(rpl=false)then
       if((gstp mod vid_h4fps)=0)then
       begin
          _wudata_byte(_players[_pl].cmana,rpl);
       end;
      if((gstp mod vid_fps)=0)then
      begin
         _wupgrades(pp,rpl);
      end;

      _wudata_int(puint^,rpl);
      for i:=1 to _PNU do
      begin
         repeat
           inc(puint^,1);
           if(puint^<1)or(puint^>MaxUnits)then puint^:=1;
         until ( ( pp and (1 shl (((puint^-1)div MaxPlayerUnits)+1)) ) > 0 );
         _wudata(@_units[puint^],rpl,_pl);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

{$IFDEF _FULLGAME}

// player counters

procedure _ncl_create(pu:PTUnit);
begin
   with pu^ do
   with _players[player] do
   begin
      inc(uid_e[uid],1);
      if(puid^._itbuild)
      then inc(uid_b,1)
      else inc(uid_u,1);
      inc(army,1);
      if(inapc>0)then inc(_units[inapc].apcc,1);

      if(sel)then _unit_selcntinc(pu);
      if(hits>0)then
       if(bld)then
       begin
          _unit_bldcntinc(pu);
          inc(menerg,puid^._generg);
       end
       else inc(cenerg,puid^._renerg);
      if(un_r>0)then
      begin
         inc(uidip[un_t],1);
         inc(uidsip,1);
         inc(cenerg,_tuids[un_t]._renerg);
      end;
      if(up_r>0)then
      begin
         inc(upgrip[up_t],1);
         inc(upgrsip,1);
         inc(cenerg,_tupids[up_t]._uprenerg);
      end;
   end;
end;

procedure _ncl_remove(pu:PTUnit);
begin
   with pu^ do
   with _players[player] do
   begin
      dec(uid_e[uid],1);
      if(puid^._itbuild)
      then dec(uid_b,1)
      else dec(uid_u,1);
      dec(army,1);
      if(inapc>0)then dec(_units[inapc].apcc,1);

      if(sel)then _unit_selcntdec(pu);
      if(hits>0)then
       if(bld)then
       begin
          _unit_bldcntdec(pu);
          dec(menerg,puid^._generg);
       end
       else dec(cenerg,puid^._renerg);
      if(un_r>0)then
      begin
         dec(uidip[un_t],1);
         dec(uidsip,1);
         dec(cenerg,_tuids[un_t]._renerg);
      end;
      if(up_r>0)then
      begin
         dec(upgrip[up_t],1);
         dec(upgrsip,1);
         dec(cenerg,_tupids[up_t]._uprenerg);
      end;
   end;
end;

// Compare unit states: previous[0] and new

procedure _netSetUcl(cu:PTUnit);
var pu:PTUnit;
begin
   pu:=@_units[0];
   with (cu^) do
    with _players[player] do
     if(pu^.hits<=dead_hits)and(hits>dead_hits)then // create
     begin
        _unit_def(cu);

        vx:=x;
        vy:=y;

        _unit_upgr(cu);
        _ncl_create(cu);

        if(hits>0)and(buff[ub_born]>0)then _ueff_create(cu);

        if(buff[ub_teleff]>0)then
        begin
           _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
           PlayUSND(snd_teleport,cu);
        end;
     end
     else
      if(pu^.hits>dead_hits)and(hits<=dead_hits)then // remove
      begin
         vx:=x;
         vy:=y;

         _unit_upgr(cu);
         _ncl_remove(pu);

         if(hits>ndead_hits)and(inapc=0)then
          if(pu^.hits>0)then _ueff_death(cu,hits<=idead_hits);
      end
      else
       if(pu^.hits>dead_hits)and(hits>dead_hits)then // a to a
       begin
          if(pu^.uid<>uid)then _unit_def(cu);

          _unit_upgr(cu);

          _ncl_remove(pu);
          _ncl_create(cu);

          if(pu^.hits<=0)and(hits>0)then // d to a
          begin
             _unit_clfog(pu);
             vx:=x;
             vy:=y;
             _ueff_create(cu);
          end
          else
           if(pu^.hits>0)and(hits<=0)then // a to d
           begin
              _ueff_death(cu,hits<=idead_hits);
           end
           else                             // a to a or d to d
            if(hits>0)then
            begin
               if(pu^.buff[ub_pain]=0)and(buff[ub_pain]>0)then _ueff_pain(pu);
            end;

          if(pu^.buff[ub_born  ]=0)and(buff[ub_born  ]>0)then _ueff_create(cu);

          if(pu^.inapc<>inapc)then PlayUSND(snd_inapc,cu);

          if(pu^.x<>x)or(pu^.y<>y)then
          begin
             _unit_sfog(cu);
             _unit_mmcoords(cu);
             if(pu^.buff[ub_teleff]=0)and(buff[ub_teleff]>0)then
             begin
                vx:=x;
                vy:=y;
                _effect_add(pu^.vx,pu^.vy,pu^.vy+map_flydpth[uf]+1,EID_Teleport);
                _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
                if(_nhp3(vx,vy,player) or _nhp3(pu^.vx,pu^.vy,player))then PlayUSND(snd_teleport);
             end;
             if(speed>0)then vstp:=UnitStepNum;
             if(mv_x<>x)or(mv_y<>y)then mdir:=p_dir(mv_x,mv_y,x,y);
             mv_x:=x;
             mv_y:=y;
             pains:=net_unmvsts;
          end
          else
            if(pains>0)then dec(pains,1);
       end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////   CLIENT
////////////////////////////////////////////////////////////////////////////////

function _rudata_byte(rpl:boolean;def:byte    =0):byte;
begin
   if(rpl=false)
   then _rudata_byte:=net_readbyte
   else begin {$I-} BlockRead(_rpls_file,_rudata_byte,SizeOf(_rudata_byte));if(ioresult<>0)then _rudata_byte:=def; {$I+} end;
end;

function _rudata_sint(rpl:boolean;def:shortint=0):shortint;
begin
   if(rpl=false)
   then _rudata_sint:=net_readsint
   else begin {$I-} BlockRead(_rpls_file,_rudata_sint,SizeOf(_rudata_sint));if(ioresult<>0)then _rudata_sint:=def; {$I+} end;
end;

function _rudata_int(rpl:boolean;def:integer  =0):integer;
begin
   if(rpl=false)
   then _rudata_int:=net_readint
   else begin {$I-} BlockRead(_rpls_file,_rudata_int ,SizeOf(_rudata_int ));if(ioresult<>0)then _rudata_int :=def; {$I+} end;
end;

function _rudata_card(rpl:boolean;def:cardinal=0):cardinal;
begin
   if(rpl=false)
   then _rudata_card:=net_readcard
   else begin {$I-} BlockRead(_rpls_file,_rudata_card,SizeOf(_rudata_card));if(ioresult<>0)then _rudata_card:=def; {$I+} end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure _rudata_bstat(pu:PTUnit;rpl:boolean);
var _dvsn:boolean;
    _vsn,
    _bts1,
    _bts2:byte;
begin
   with (pu^) do
   with (puid^) do
   begin
      _bts1:=_rudata_byte(rpl);

      _dvsn:=GetBBit(@_bts1,0);
      bld:=GetBBit(@_bts1,1);
      if(GetBBit(@_bts1,2))
      then inapc:=1
      else inapc:=0;
      buff[ub_advanced  ]:=_buffst[GetBBit(@_bts1,3)];

      if(hits>0)then
      begin
         buff[ub_invis   ]:=_buffst[GetBBit(@_bts1,4)];
         buff[ub_pain    ]:=_buffst[GetBBit(@_bts1,5)];
      end
      else buff[ub_resur ]:=_buffst[GetBBit(@_bts1,4)];

      if(GetBBit(@_bts1,7))
      then _bts2:=_rudata_byte(rpl)
      else _bts2:=0;

      buff[ub_teleff   ]:=_buffst[GetBBit(@_bts2,0)];
      buff[ub_invuln   ]:=_buffst[GetBBit(@_bts2,1)];
      buff[ub_born     ]:=_buffst[GetBBit(@_bts2,2)];
      buff[ub_cast     ]:=_buffst[GetBBit(@_bts2,3)];

      if(_dvsn)
      then _vsn:=_rudata_byte(rpl)
      else _vsn:=1+(1 shl _players[player].team);

      for _bts2:=0 to MaxPlayers do
       if(GetBBit(@_vsn,_bts2))
       then vsnt[_bts2]:=_bufinf
       else vsnt[_bts2]:=0;

      if(GetBBit(@_bts1,2)=false)and(GetBBit(@_bts1,4))and(hits>0)
      then _vsn:=_rudata_byte(rpl)
      else _vsn:=1+(1 shl _players[player].team);

      for _bts2:=0 to MaxPlayers do
       if(GetBBit(@_vsn,_bts2))
       then vsni[_bts2]:=_bufinf
       else vsni[_bts2]:=0;
   end;
end;

procedure _rudata(pu:PTUnit;rpl:boolean;_pl:byte;explayer:byte=255;uded:boolean=false);
var sh    :shortint;
    i,
    _bts1,
    _bts2 :byte;
begin
   _units[0]:=pu^;

   if(rpl)then _pl:=0;

   with (pu^) do
   begin
      if(uded)
      then sh:=-128
      else sh:=_rudata_sint(rpl,-128);

      if(sh>-127)then
      begin
         if(explayer=255)
         then player:=((unum-1)div MaxPlayerUnits)+1
         else player:=explayer;

         uid:=_rudata_byte(rpl);
         _unit_sclass(pu);
         with(puid^) do hits:=_S2hi(sh,_mhits,_shcf);

         sel      :=false;
         un_r     :=0;
         up_r     :=0;
         uo_id [0]:=0;
         uo_tar[0]:=0;
         uo_x  [0]:=0;
         uo_y  [0]:=0;
         uo_n     :=0;
         order    :=0;
         inapc    :=0;
         ca_x     :=0;
         ca_y     :=0;
         ca_tar   :=0;
         aattack  :=false;
         aorder   :=0;
         FillChar(buff,SizeOf(buff),0);

         _rudata_bstat(pu,rpl);

         if(inapc>0)then
         begin
            inapc:=_rudata_int(rpl);
            if(inapc<0       )then inapc:=0;
            if(inapc>MaxUnits)then inapc:=MaxUnits;
         end
         else
         begin
            if(sh>0)then
            begin
               x:=_rudata_int(rpl);
               y:=_rudata_int(rpl);
            end
            else
            begin
               x:=integer(_rudata_byte(rpl) shl 5)+(x mod 32);
               y:=integer(_rudata_byte(rpl) shl 5)+(y mod 32);
            end;
         end;

         if(hits>0)then
         begin
            _bts1:=_rudata_byte(rpl);

            if(player=_pl)and(inapc=0)then
            with(puid^) do
            begin
               if(GetBBit(@_bts1,3))then
               begin
                  un_t:=_rudata_byte(rpl);
                  un_r:=_rudata_int (rpl);
               end;
               if(GetBBit(@_bts1,4))then
               begin
                  up_t:=_rudata_byte(rpl);
                  up_r:=_rudata_int (rpl);
               end;
               if(GetBBit(@_bts1,5))then order:=_rudata_byte(rpl);

               if(GetBBit(@_bts1,2))then
               begin
                  sel:=true;
                  if(uo_rallpos in _orders)then
                  begin
                     un_rtar:=_rudata_int(rpl);
                     if(un_rtar>MaxUnits)then
                     begin
                        un_rx:=un_rtar-MaxUnits;
                        un_ry:=_rudata_int(rpl);
                     end
                     else
                     begin
                        un_rx:=_units[un_rtar].vx;
                        un_ry:=_units[un_rtar].vy;
                     end;
                  end;
                  _bts2  :=_rudata_byte(rpl);
                  aattack:=GetBBit(@_bts2,7);
                  aorder :=_bts2 and %01111111;
               end;
               if(GetBBit(@_bts1,6))then
               begin
                  uo_n:=_rudata_byte(rpl);
                  for i:=0 to uo_n do
                  begin
                     uo_id [i]:=_rudata_byte(rpl);
                     if((_toids[uo_id[i]].rtar and at_unit)>0)or(uo_id[i]=uo_prod)then uo_tar[i]:=_rudata_int (rpl);
                     if((_toids[uo_id[i]].rtar and at_map )>0)then
                     begin
                        uo_x  [i]:=_rudata_int (rpl);
                        uo_y  [i]:=_rudata_int (rpl);
                     end;
                  end;
               end;
            end;

            _bts2:=_bts1 and %00000011;
            if(_bts2 < %00000011)then
            begin
               a_weap:=_bts2;
               if(a_weap>MaxAttacks)then a_weap:=0;

               if((puid^._a_weap[a_weap].aw_req and wpr_netst)>0)
               then ca_tar:=_rudata_int(rpl)
               else
               begin
                  ca_x  :=_rudata_sint(rpl);
                  ca_y  :=_rudata_sint(rpl);
               end;
               if(ca_tar<0)or(MaxUnits<ca_tar)then ca_tar:=0;
            end;
         end;
      end
      else
        with(puid^) do hits:=_S2hi(sh,_mhits,_shcf);

      if(rpl)then
       if(_rpls_step>2)then
       begin
          vx:=x;
          vy:=y;
       end;
   end;

   _netSetUcl(pu);
end;

procedure _rupgrades(pp:byte;rpl:boolean);
var i,p,
    b,v:byte;
begin
   for p:=1 to MaxPlayers do
    if((pp and (1 shl p))>0)then
     with _players[p] do
     begin
        v:=0;
        b:=0;
        for i:=1 to 255 do
         with _tupids[i] do
          if(_urace=race)or(_urace=255)then
          begin
             if((b mod 2)=0)then
             begin
                v:=_rudata_byte(rpl);
                upgr[i]:=v and %00001111;
             end
             else upgr[i]:=v shr 4;
             inc(b,1);
          end;
     end;
end;

procedure _rclient_reclcustp(PNU,mxun:word);
begin
   if(PNU>0)then
   begin
      net_unmvsts:=trunc(mxun/PNU)*NetTickN+1;
      if(net_unmvsts<MinUSTP)
      then UnitStepNum:=MinUSTP
      else UnitStepNum:=net_unmvsts;

      if(net_unmvsts<=8)
      then net_unmvsts:=10-net_unmvsts
      else net_unmvsts:=2;
   end
   else
   begin
      UnitStepNum:=MinUSTP;
      net_unmvsts:=MinUSTP;
   end;
end;

procedure _rclinet_gframe(_pl:byte;rpl:boolean);
var gstp : cardinal;
    pp,ep: byte;
    uint: integer;
    i,
    _PNU,
    ucnt: word;
begin
   G_Step:=_rudata_card(rpl,G_Step);
   pp    :=_rudata_byte(rpl);
   if(pp>0)then
   begin
      _PNU:=_rudata_byte(rpl)*3;

      ucnt:=0;
      for i:=1 to MaxPlayers do
       if((pp and (1 shl i))>0)then inc(ucnt,MaxPlayerUnits);

      if(_PNU>ucnt)then _PNU:=ucnt;

      with _players[_pl] do
      begin
         if(nport<>_PNU)or(n_u<>ucnt)then _rclient_reclcustp(_PNU,ucnt);
         n_u  :=ucnt;
         nport:=_PNU;
      end;

      if(rpl=false)then _players[_pl]._lsuc:=_rudata_byte(rpl);

      gstp:=G_Step shr 1;
      if(rpl=false)then
       if((gstp mod vid_h4fps)=0)then
       begin
          _players[_pl].cmana:=_rudata_byte(rpl);
       end;
      if((gstp mod vid_fps)=0)then
      begin
         _rupgrades(pp,rpl);
      end;

      uint:=_rudata_int(rpl);
      for i:=1 to _PNU do
      begin
         gstp:=0;
         while (gstp=0) do
         begin
            inc(uint,1);
            if(uint<1)or(uint>MaxUnits)then uint:=1;
            ep  :=((uint-1)div MaxPlayerUnits)+1;
            gstp:=pp and (1 shl ep);
            _rudata(@_units[uint],rpl,_pl,ep,(gstp=0));
         end;
      end;
   end;
end;

{$ENDIF}

