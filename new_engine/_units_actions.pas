

function _attackweap(pu,tu:PTUnit):byte;
var a:byte;
begin
   _attackweap:=255;

   with(pu^)do
    with(puid^)do
     for a:=0 to MaxAttacks do
     with _a_weap[a] do
     begin
         if(_uchtar(tu,aw_tar,aw_taru,player)=false)then continue;
         if(_urace>0)then
          with _players[player] do
           if(aw_rupgr>0)and(upgr[aw_rupgr]=0)then continue;
         case aw_req of
         wpr_any : ;
         wpr_adv : if(buff[ub_advanced ]=0)then continue;
         wpr_nadv: if(buff[ub_advanced ]>0)then continue;
         end;
         case aw_type of
         wpt_ddmg,
         wpt_msle: ;
         wpt_resur  : if(tu^.buff[ub_resur]>0)or(tu^.hits<=idead_hits)or(rdead_hits<=tu^.hits)then continue;
         wpt_heal   : if(tu^.hits<=0)or(tu^.hits>=tu^.puid^._mhits)then continue;
         end;
         _attackweap:=a;
         break;
     end;
end;

function _canattacktar(pu,tu:PTUnit;voobshe:boolean;wp:byte=255;sd:integer=-1):byte;
var td:integer;
begin
   _canattacktar:=0;

   with(pu^)do
    with(puid^)do
    begin
       if(wp>MaxAttacks)then exit;

       if(sd= -1)then sd:=dist(x,y,tu^.x,tu^.y);

       if(a_rng[wp]<0)then
       begin
          if(inapc>0)then exit;
          td:=sd-(_r+tu^.puid^._r+speed)
       end
       else
         if(a_rng[wp]=0)
         then td:=sd-srng
         else td:=sd-a_rng[wp];

       if(td<=0)
       then _canattacktar:=2
       else
         if(speed>0)and(uo_id[0]<>uo_hold)and(inapc=0)then
          if(voobshe)
          then _canattacktar:=1
          else
            if(sd<=srng)then _canattacktar:=1;
    end;

   {
   0 - не может
   1 - должен подойти
   2 - может прямо сейчас
   }
end;

function _target_check(pu,tu:PTUnit):byte;
var awp:byte;
begin
   _target_check:=255;

   with pu^.puid^ do
    if(_itattack=0)then exit;
   awp:=_attackweap(pu,tu);
   if(awp>MaxAttacks)then exit;
   if(_canattacktar(pu,tu,true,awp,-1)=0)then exit;
   with (pu^) do
    with _players[player] do
     if(_uvision(team,tu)=false)then exit;

   _target_check:=awp;
end;

procedure _unit_ord_auto(pu:PTUnit;aid:byte;b:boolean);
begin
   with pu^ do
   begin
      if(aid=uo_attack)
      then aattack:=b
      else
        if(_toids[aid].cauto)then
         if(b)
         then aorder:=aid
         else aorder:=0;
   end;
end;

procedure _unit_ord_rally(pu:PTUnit;tar,tx,ty:integer);
begin
   with pu^ do
   begin
      if(tar>0)and(tar<=MaxUnits)then
      begin
         un_rtar:=tar;
         un_rx  :=_units[un_rtar].x;
         un_ry  :=_units[un_rtar].y;
      end
      else
      begin
         un_rtar:=0;
         un_rx  :=tx;
         un_ry  :=ty;
      end;
   end;
end;

function _unit_setorder(pu:PTUnit;ac_id:byte;ac_tar,ac_x,ac_y:integer;aicall,add:boolean):boolean;
var tu:PTUnit;
 uon,w:byte;
begin
   _unit_setorder:=false;
   with(pu^)do
    if(hits>0)then
     with(puid^)do
     begin
        if(add=false)
        then uon :=1
        else
        begin
          case uo_id[uo_n] of
          uo_hold,
          uo_destroy: exit;
          uo_patrol,
          uo_spatrol: if not(ac_id in [uo_patrol,uo_spatrol])then exit;
          else
          end;
          uon :=uo_n+1;
        end;
        if(uon>=MaxOrderList)then exit;

        if(ac_id=uo_rightcl)then
        begin
           with _players[player] do
            if(rghtatt)and(_itattack>0)
            then ac_id:=uo_attack
            else ac_id:=uo_move;

           if(uo_rallpos in _orders)then ac_id:=uo_rallpos;

           if(ac_tar>0)and(ac_tar<=MaxUnits)then
           begin
              tu:=@_units[ac_tar];
              w:=_target_check(pu,tu);
              if(w<=MaxAttacks)
              then ac_id:=_a_weap[w].aw_order
              else
                if(_itcanapc(pu,tu)or _itcanapc(tu,pu))
                then ac_id:=uo_upload
                else
                  if(_itbuild=false)and(tu^.uid in _toids[uo_uteleport].rtaru)and(tu^.bld)
                  then ac_id:=uo_uteleport
                  else
                    if(ac_id=uo_attack)then ac_id:=uo_move;
           end;
        end;

        if(_chabil (ac_id,uid,player,ac_tar,bld,speed)=false)
        or(_chabilt(ac_id    ,player,ac_tar          )=false)then exit;

        case ac_id of
        uo_prod:
           with _players[player] do
           begin
              if(ac_tar<0)then
              begin
                 if(_tuids[-ac_tar]._itbuild=false)and(race_pstyle[false,race]=false)then // classic unit prod order
                 begin
                    if(add)then exit;
                    if(_sbrcks>0)and(sel=false)then exit;
                    if(ac_x>=0)then
                    begin
                       if(_unit_sunt(pu,-ac_tar)=false)then exit;
                    end
                    else
                      if(_unit_cunt(pu,-ac_tar)=false)then exit;
                    if(_sbrcks=0)then _unit_setorder:=true;
                 end
                 else
                 begin
                    if(_tuids[-ac_tar]._itbuild=true)and(race_pstyle[true,race]=false)then // dron build
                    begin
                       if(aicall=false)then
                        if(sel=false)then exit;
                       if(_uordl_find(pu,uo_prod)<255)and(_sbldrs>1)then exit;
                    end
                    else
                      if(add)then exit;
                    uo_id  [uon]:= ac_id;
                    uo_tar [uon]:= ac_tar;
                    uo_x   [uon]:= ac_x;
                    uo_y   [uon]:= ac_y;
                    _unit_setorder:=true;
                 end;
              end
              else
               if(0<ac_tar)then // upgr
               begin
                  if(add)then exit;
                  if(_ssmths>0)and(sel=false)then exit;
                  if(ac_x>=0)then
                  begin
                     if(_unit_supt(pu,ac_tar)=false)then exit;
                  end
                  else
                    if(_unit_cupt(pu,ac_tar)=false)then exit;
                  if(_ssmths=0)then _unit_setorder:=true;
               end;
           end;
        uo_patrol:
           begin
              ac_tar:=_uordl_find(pu,uo_spatrol);

              if(ac_tar=255)or(add=false)then
              begin
                 if(add=false)
                 then uo_n:=1
                 else inc(uo_n,2);

                 uo_id  [uon]:= uo_spatrol;
                 uo_tar [uon]:= 0;
                 uo_x   [uon]:= -1;
                 uo_y   [uon]:= -1;
                 inc(uon,1);
                 uo_id  [uon]:= uo_patrol;
                 uo_tar [uon]:= 0;
                 uo_x   [uon]:= ac_x;
                 uo_y   [uon]:= ac_y;
              end
              else
              begin
                 if(add)then
                  if(uo_id[0] in [uo_patrol,uo_spatrol])and(ac_tar>0)
                  then _uordl_insert(pu,ac_tar,uo_patrol,ac_x,ac_y,0)
                  else _uordl_insert(pu,255   ,uo_patrol,ac_x,ac_y,0);
              end;
           end;

        else
           with _toids[ac_id] do _unit_setorder:=not toall;

           if(add)then
             case ac_id of
             uo_rallpos: exit;
             end
           else
             case ac_id of
             uo_auto:
                begin
                   _unit_ord_auto(pu,ac_tar,ac_x=0);
                   exit;
                end;
             uo_rallpos:
                begin
                   _unit_ord_rally(pu,ac_tar,ac_x,ac_y);
                   exit;
                end;
             end;

           uo_id  [uon]:= ac_id;
           uo_tar [uon]:= ac_tar;
           uo_x   [uon]:= ac_x;
           uo_y   [uon]:= ac_y;
        end;

        uo_n:=uon;
        if(add=false)then
        begin
           uo_id  [0]:= uo_stop;
           uo_tar [0]:= 0;
           uo_x   [0]:= x;
           uo_y   [0]:= y;
        end;
        //clrscr;
        //writeln(uo_n);
        //for uon:=0 to uo_n do writeln(' ',uo_id[uon]);
     end;
end;

procedure _barrack_spawn(pu:PTUnit;suid:byte;spawneff:boolean=true);
const ditstepx : array[0..7] of integer = (1,1 , 0,-1,-1,-1,0,1);
const ditstepy : array[0..7] of integer = (0,-1,-1,-1,0 , 1,1,1);
var tx,
    ty:integer;
    sd:byte;
begin
   with (pu^) do
   with (puid^) do
   begin
      if(_tuids[suid]._uf>uf_ground)and(_itbuild)then
      begin
         tx:=x;
         ty:=y;
      end
      else
      begin
         sd:=((tdir+23) mod 360) div 45;
         ty:=_r+_tuids[suid]._r;
         tx:=x+ditstepx[sd]*ty;
         ty:=y+ditstepy[sd]*ty;
      end;

      _unitCreate(tx,ty,suid,player,true,spawneff);
      if(_lcu>0)then
      begin
         if(uo_rallpos in _orders)then _unit_setorder(_lcup,uo_rightcl,un_rtar,un_rx,un_ry,true,false);
         _lcup^.mdir:=mdir;
         _lcup^.tdir:=tdir;
      end;
   end;
end;

procedure _nextOrder(pu:PTUnit);
begin
   with(pu^)do
   if(uo_n=0)then
   begin
      uo_id [0]:=uo_stop;
      uo_tar[0]:=0;
      uo_x  [0]:=x;
      uo_y  [0]:=y;
   end
   else
   begin
      _uordl_cut(pu,0);
      with _toids[uo_id[0]] do
       if((rtar and at_anytar)>0)then
        with(puid^)do
        begin
           if(uo_x[0]>=0)and(_fastturn)and(speed>0)then mdir := p_dir(x,y,uo_x[0],uo_y[0],mdir);
        end;
   end;
end;

procedure _unit_order(pu:PTUnit);
var at:integer;
   ptu:PTUnit;
   pud:PTUID;
begin
   with(pu^)do
    with(puid^)do
    begin
       if(uo_id[0]=uo_rightcl)
       or(_chabil (uo_id[0],uid,player,uo_tar[0],bld,speed)=false)
       or(_chabilt(uo_id[0]    ,player,uo_tar[0]          )=false)then
       begin
          _nextOrder(pu);
          exit;
       end;

       case uo_id[0] of
       uo_prod:
             if(-255<=uo_tar[0])and(uo_tar[0]<=0)then
             begin
                at :=dist(x,y,uo_x[0],uo_y[0]);
                pud:=@_tuids[-uo_tar[0]];
                case pud^._itbuild of
                true : with _players[player] do
                       if(race_pstyle[true, race]=false)then  // UAC style
                       begin
                           mv_x := uo_x[0];
                           mv_y := uo_y[0];
                           if(at>=pud^._r)then
                           begin
                              if(speed<=0)then _nextOrder(pu);
                              exit;
                           end;
                       end;
                false: with _players[player] do
                       if(race_pstyle[false,race]=false)then  // classic style
                       begin
                          _nextOrder(pu);
                          exit;
                       end;
                end;

                if(_unitBC(player,-uo_tar[0])=false)and(_unit_grbcol(uo_x[0],uo_y[0],pud^._r,player,pud^._uf,true,pud^._itbuild)=0)then
                begin
                   _unitCreate(uo_x[0],uo_y[0],-uo_tar[0],player,false,true);
                   if(_lcu>0)then
                    if(pud^._itbuild)and(race_pstyle[pud^._itbuild,_players[player].race]=false)then
                    begin
                       inapc :=_lcu;
                       inc(_lcup^.apcc,_apcs);
                       if(sel)then
                       begin
                          _unit_selcntdec(pu);
                          sel:=false;
                       end;
                    end
                    else
                      with _players[player] do dec(cmana,race_bsmana[pud^._itbuild,race]);
                end;
                _nextOrder(pu);
             end
             else _nextOrder(pu);
       uo_move,
       uo_smove:
             begin
                if(uo_tar[0]>0)and(uclord=_uclord_c)then
                begin
                   at:=0;
                   ptu:=@_units[uo_tar[0]];
                   if(_uvision(_players[pu^.player].team,ptu)=false)or(ptu^.inapc>0)
                   then uo_tar[0]:=0
                   else at:=-ptu^.puid^._r;
                   uo_x[0]:=ptu^.x;
                   uo_y[0]:=ptu^.y;
                   inc(at,dist2(x,y,uo_x[0],uo_y[0])-_r);
                end
                else
                  if(uo_id[0]=uo_move)
                  then at:=dist2(x,y,uo_x[0],uo_y[0])
                  else at:=0;

                if(at<=speed)or(speed=0)then
                begin
                   mv_x  :=x;
                   mv_y  :=y;
                   if(uo_tar[0]=0)
                   then _nextOrder(pu)
                   else uo_id[0]:=uo_smove;
                end
                else
                begin
                   mv_x    :=uo_x[0];
                   mv_y    :=uo_y[0];
                   uo_id[0]:=uo_move;
                end;
             end;
       uo_rightcl,
       uo_stop:
             begin
                mv_x:=x;
                mv_y:=y;
                _nextOrder(pu);
             end;
       uo_hold:
             begin
                mv_x:=x;
                mv_y:=y;
             end;
       uo_spatrol,
       uo_patrol:
             begin
                if(uo_x[0]=-1)then
                begin
                   uo_x[0]:=x;
                   uo_y[0]:=y;
                   mv_x:=x;
                   mv_y:=y;
                end;
                if(uclord=_uclord_c)then
                begin
                   if(x=uo_x[0])and(y=uo_y[0])then
                   begin
                      repeat _uordl_roll(pu);until uo_id[0] in [uo_patrol,uo_spatrol];
                      if(_fastturn)then mdir :=p_dir(x,y,uo_x[0],uo_y[0],mdir);
                   end;
                   mv_x:=uo_x[0];
                   mv_y:=uo_y[0];
                end;
             end;
       uo_rallpos:
             begin
                _unit_ord_rally(pu,uo_tar[0],uo_x[0],uo_y[0]);
                _nextOrder(pu);
             end;
       uo_auto:
             begin
                _unit_ord_auto(pu,uo_tar[0],uo_x[0]=0);
                _nextOrder(pu);
             end;
       uo_unload:
             begin
                _unit_unload(pu);
                _nextOrder(pu);
             end;
       uo_upload:
             if(uo_tar[0]<=0)or(uo_tar[0]>MaxUnits)
             then _nextOrder(pu)
             else
               if(uclord=_uclord_c)then
               begin
                  ptu :=@_units[uo_tar[0]];
                  if(ptu^.inapc>0)then
                  begin
                     _nextOrder(pu);
                      exit;
                  end;
                  uo_x[0]:=ptu^.x;
                  uo_y[0]:=ptu^.y;
                  mv_x:=uo_x[0];
                  mv_y:=uo_y[0];
                  at  :=dist2(x,y,uo_x[0],uo_y[0])-_r-ptu^.puid^._r;
                  if(at<=10)then
                  begin
                     if(_itcanapc(pu,ptu))then
                     begin
                        _loadunit(pu,ptu);
                        mv_x  :=x;
                        mv_y  :=y;
                     end
                     else
                       if(_itcanapc(ptu,pu))then _loadunit(ptu,pu);
                     _nextOrder(pu);
                  end;
               end;
       uo_uteleport:
             begin
                if(uo_tar[0]<=0)or(uo_tar[0]>MaxUnits)or(_itbuild)then begin _nextOrder(pu);exit;end;
                ptu:=@_units[uo_tar[0]];

                mv_x := uo_x[0];
                mv_y := uo_y[0];
                if(uclord=_uclord_c)and(ptu^.a_rld<=0)then
                begin
                   at  :=dist2(x,y,uo_x[0],uo_y[0])-ptu^.puid^._r;
                   if(at<=0)then
                   begin
                      _unit_uteleport(pu,ptu^.un_rx,ptu^.un_ry);
                      ptu^.a_rld:=puid^._renerg*vid_fps;
                      _nextOrder(pu);
                   end;
                end;
             end;
       uo_spawndron:
             with _players[player] do
             begin
                _barrack_spawn(pu,UID_Dron,true);
                dec(cmana,_toids[uo_id[0]].rmana);
                _nextOrder(pu);
             end;
       uo_spawnlost:
             if(buff[ub_cast]=0)and(a_rld=0)then
             begin
                _barrack_spawn(pu,UID_LostSoul,false);
                buff[ub_cast]:=vid_fps+vid_h2fps;
                _nextOrder(pu);
             end;
       uo_destroy: _unit_kill(pu,false,false);
       else
          if(_toids[uo_id[0]].r2attack)then
          begin
             if(uo_tar[0]>0)and(uo_tar[0]<=MaxUnits)then
             begin
                ptu :=@_units[uo_tar[0]];
                if(_target_check(pu,ptu)<=MaxAttacks)then
                begin
                   uo_x[0]:= ptu^.x;
                   uo_y[0]:= ptu^.y;
                   a_tar  := uo_tar[0];
                end
                else uo_tar[0]:=0;
             end
             else uo_tar[0]:=0;
             if(uo_tar[0]=0)and(uo_id[0]<>uo_attack)then a_tar:=uo_tar[0];

             at  :=dist2(x,y,uo_x[0],uo_y[0]);
             if(uo_tar[0]=0)then
              if(at<=2)or(speed=0)
              then _nextOrder(pu)
              else
              begin
                 mv_x := uo_x[0];
                 mv_y := uo_y[0];
              end;
          end
       end;
    end;

end;

function calc_cx(iw:integer;m2:boolean):shortint;
const _mm = 1000;
begin
   if(iw<-_mm)then iw:=-_mm;
   if(iw> _mm)then iw:= _mm;
   calc_cx:=_intm2(iw shr 3,m2);
end;

procedure _unit_attproc(pu:PTUnit;_ttar,_tx,_ty:integer;_tuf,_wp:byte);
var _tu  :PTUnit;
    _msx,
    _msy :integer;
begin
   with(pu^)do
    with(puid^)do
     with _players[player] do
     begin
        _msx:=vx;
        _msy:=vy;

        if(0<_ttar)and(_ttar<=MaxUnits)then
        begin
           _tu  :=@_units[_ttar];
           _tx  := _calcMslPoint(_msx,_tu,true );
           _ty  := _calcMslPoint(_msy,_tu,false);
           _tuf := _tu^.uf;

           if(OnlySVCode)then _addtoint(@vsnt[_players[_tu^.player].team],vid_fps);
        end;

        if(a_rld=0)then
        begin
           a_weap:=_wp;
           a_rld :=_a_weap[a_weap].aw_rldt;
        end;

        with _a_weap[a_weap] do
        if(a_rld=aw_rlds)then
        begin
           {$IFDEF _FULLGAME}
           PlayUSND(aw_snd,pu);
           {$ENDIF}
           case aw_type of
           wpt_msle  : _miss_add(_tx,_ty,_msx,_msy,_ttar,aw_mid,player,_tuf,0);
           wpt_uspwn : if((army+uidsip)<MaxPlayerUnits)then
                       begin
                          if(OnlySVCode)then
                          begin
                             _barrack_spawn(pu,aw_mid,false);
                             if(_lcu>0)then
                             begin
                                {$IFDEF _FULLGAME}
                                PlayUSND(_ueff2snd(aw_mid,ueff_create,false),pu);
                                {$ENDIF}
                                _unit_setorder(_lcup,uo_rightcl,_ttar,_tx,_ty,true,false);
                                _lcup^.mdir:=mdir;
                                _lcup^.tdir:=tdir;
                             end;
                          end;
                       end
                       else
                       begin
                          {$IFDEF _FULLGAME}
                          PlayUSND(_ueff2snd(aw_mid,ueff_death,false),pu);
                          {$ENDIF}
                       end;
           else
             if(OnlySVCode)and(_ttar>0)then
              case aw_type of
             wpt_resur : _tu^.buff[ub_resur]:=vid_2fps;
             wpt_heal  : begin
                            inc(_tu^.hits,aw_mdmg);
                            if(_tu^.hits>_tu^.puid^._mhits)then _tu^.hits:=_tu^.puid^._mhits;
                         end;
             wpt_ddmg  : _unit_damage(_tu,aw_mdmg,1);
              end;
           end;
        end;

        if(OnlySVCode)and(a_weap=_wp)then
        begin
           ca_tar:=0;
           if(0<_ttar)and(_ttar<=MaxUnits)then
           begin
              //inc(_tx,(_tu^.x-_tu^.vx)*2);
              //inc(_ty,(_tu^.y-_tu^.vy)*2);
              ca_tar:=_tu^.unum;
           end;
           ca_x :=calc_cx(_tx-_msx,(_tuf=uf_soaring));
           ca_y :=calc_cx(_ty-_msy,(_tuf=uf_fly    ));
        end;
        if(_itattack>=atm_inmove)and(inapc=0)then tdir:=p_dir(_msx,_msy,_msx+ca_x,_msy+ca_y,tdir);
     end;
end;


// server attack
procedure _unit_attack(pu:PTUnit);
var tu:PTUnit;
    i,
    w :byte;
begin
   with(pu^)do
    with(puid^)do
     with _players[player] do
     begin
        tu:=@_units[a_tar];

        w:=_attackweap(pu,tu);
        if(w>MaxAttacks)then
        begin
           a_tar:=0;
           exit;
        end;

        i:=_canattacktar(pu,tu,true,w,-1);

        case i of
0:        begin
             a_tar:=0;
          end;
1:        begin
             mv_x:=tu^.x;
             mv_y:=tu^.y;
          end;
2,
3:        begin
             if(_itattack<>atm_inmove)or((uo_id[0]=uo_attack)and(uo_tar[0]=a_tar))then
             begin
                mv_x:=x;
                mv_y:=y;
             end;
             _unit_attproc(pu,a_tar,0,0,0,w);
          end;
        end;
     end;
end;

// client attack
procedure _unit_clattack(pu:PTUnit);
var ca_uf:byte;
begin
   with(pu^)do
   begin
      if(0<ca_tar)and(ca_tar<=MaxUnits)
      then _unit_attproc(pu,ca_tar,0,0,0,a_weap)
      else
        if(ca_x<>0)then
        begin
           ca_uf:=0;
           if(abs(ca_x mod 2)=1)
           then ca_uf:=uf_soaring
           else
             if(abs(ca_y mod 2)=1)
             then ca_uf:=uf_fly;
           _unit_attproc(pu,0,x+(ca_x shl 3),y+(ca_y shl 3),ca_uf,a_weap);
        end;
   end;
end;

function _canthink(pu:PTUnit):boolean;
begin
   with(pu^)do
    with(puid^)do
    begin
       _canthink:=false;

       if(buff[ub_cast]>0)then exit;
       //if(a_rld>0)then exit;
       if(_itmech=false)then
        if(buff[ub_pain]>0)then exit;

       _canthink:=true;
    end;
end;

procedure _unit_think(pu:PTUnit);
begin
   with(pu^)do
    with(puid^)do
     with _players[player] do
     begin
        if(_canthink(pu)=false)then
        begin
           mv_x:=x;
           mv_y:=y;
           exit;
        end;


        if(onlySVCode=false)
        then _unit_clattack(pu)
        else
          if(inapc=0)then
          begin
             _unit_order(pu);

             if(uclord=_uclord_c)and(un_rtar>0)and(un_rtar<=MaxUnits)then
              if(_uvision(team,@_units[un_rtar]))and(_units[un_rtar].inapc=0)then
              begin
                 un_rx:=_units[un_rtar].vx;
                 un_ry:=_units[un_rtar].vy;
              end
              else un_rtar:=0;

             if(a_tar>0)and(bld)then
              with _toids[uo_id[0]] do
               if(cattack)or(r2attack)then _unit_attack(pu);
          end
          else
          begin
             if(a_tar>0)and(bld)then _unit_attack(pu);
          end;

        if(a_rld=0)then tdir:=mdir;
     end;
end;

