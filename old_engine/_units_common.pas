{$IFDEF _FULLGAME}
procedure _unit_mmcoords(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
   end;
end;

procedure _unit_createsound(uid:integer);
begin
   case uid of
UID_LostSoul   : PlaySND(snd_d0         ,nil);
UID_Imp        : if(random(2)=0)
                 then PlaySND(snd_impc1 ,nil)
                 else PlaySND(snd_impc2 ,nil);
UID_Demon      : PlaySND(snd_demonc     ,nil);
UID_Cacodemon  : PlaySND(snd_cacoc      ,nil);
UID_Baron      : if(G_Addon)
                 then PlaySND(snd_knight,nil)
                 else PlaySND(snd_baronc,nil);
UID_Cyberdemon : PlaySND(snd_cyberc     ,nil);
UID_Mastermind : PlaySND(snd_mindc      ,nil);
UID_Pain       : PlaySND(snd_pain_c     ,nil);
UID_Revenant   : PlaySND(snd_rev_c      ,nil);
UID_Mancubus   : PlaySND(snd_man_c      ,nil);
UID_Arachnotron: PlaySND(snd_ar_c       ,nil);
UID_ArchVile   : PlaySND(snd_arch_c     ,nil);
UID_Engineer,
UID_Medic,
UID_Sergant,
UID_Commando,
UID_Bomber,
UID_Major,
UID_BFG,
UID_FAPC,
UID_APC,
UID_Terminator,
UID_Tank,
UID_UTransport,
UID_Flyer  : case random(3) of
             0 : PlaySND(snd_uac_u0,nil);
             1 : PlaySND(snd_uac_u1,nil);
             2 : PlaySND(snd_uac_u2,nil);
             end;
UID_ZFormer,
UID_ZEngineer,
UID_ZSergant,
UID_ZCommando,
UID_ZBomber,
UID_ZMajor,
UID_ZBFG
            : case random(3) of
              0 : PlaySND(snd_z_s1,nil);
              1 : PlaySND(snd_z_s2,nil);
              2 : PlaySND(snd_z_s3,nil);
              end;
   end;
end;

procedure _unit_comssnd(ucl,race:integer);
begin
  case race of
r_hell : case ucl of
         0,2,3,
         4,5,
         6,7  : PlaySND(snd_demon1,nil);
         1    : PlaySND(snd_imp   ,nil);
         10   : PlaySND(snd_ar_act,nil);
         11   : PlaySND(snd_arch_a,nil);
         12..18,
         9    : PlaySND(snd_zomb  ,nil);
         8    : PlaySND(snd_rev_ac,nil);
         end;
r_uac  : case random(3) of
         0 : PlaySND(snd_uac_u0   ,nil);
         1 : PlaySND(snd_uac_u1   ,nil);
         2 : PlaySND(snd_uac_u2   ,nil);
         end;
  end;
end;

function _udpth(pu:PTUnit):integer;
begin
   _udpth:=0;
   with pu^ do
    case uidi of
UID_UPortal   : _udpth:=-5;
UID_HTeleport : _udpth:=-4;
UID_HSymbol,
UID_HAltar    : _udpth:=-3;
UID_UMine     : _udpth:=-2;
UID_HCommandCenter,
UID_UCommandCenter: if(uf>uf_ground)
                    then _udpth:=map_flydpth[uf_soaring]+vy
                    else
                      if(hits>0)
                      then _udpth:=map_flydpth[uf]+vy
                      else _udpth:=vy;
    else
      if(hits>0)
      then _udpth:=map_flydpth[uf]+vy
      else _udpth:=vy;
    end;
end;

procedure _unit_PowerUpEff(pu:PTUnit;snd:pMIX_Chunk);
begin
   with pu^ do
   begin
      PlaySND(snd,pu);
      _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_HUpgr);
   end;
end;

procedure _sf(tx,ty:integer);
begin
   if(0<=tx)and(0<=ty)and(tx<=fog_vfw)and(ty<=fog_vfh)then fog_grid[tx,ty]:=2;
end;

procedure _fog_sr(x,y,r:integer);
var iy,i:integer;
begin
   for i:=0 to r do
    for iy:=0 to _fcx[r,i] do
    begin
       _sf(x-i,y-iy);
       _sf(x-i,y+iy);
       if(i>0)then
       begin
          _sf(x+i,y-iy);
          _sf(x+i,y+iy);
       end;
    end;
end;

procedure _unit_sfog(pu:PTUnit);
begin
   with pu^ do
   begin
      fx :=x div fog_cw;
      fy :=y div fog_cw;
   end;
end;

function _checkvision(pu:PTUnit):byte;
begin
  _checkvision:=0;
   with pu^ do
    if(HPlayer=0)and(_rpls_rst>=rpl_rhead)
    then _checkvision:=2
    else
      if(_uvision(_players[HPlayer].team,pu,false))then
       if(player^.team=_players[HPlayer].team)
       then _checkvision:=2
       else _checkvision:=1;
end;

function _unit_fogrev(pu:PTUnit):boolean;
begin
   _unit_fogrev:=false;
   with pu^ do
   with uid^ do
    with player^ do
     if(_fog=false)
     then _unit_fogrev:=true
     else
      case _checkvision(pu) of
       1:begin
            if(_fog_cscr(fx,fy,_fr))then _fog_sr(fx-vid_fsx,fy-vid_fsy,_fr);
            _unit_fogrev:=true;
         end;
       2:begin
            if(_fog_cscr(fx,fy,fsr))then _fog_sr(fx-vid_fsx,fy-vid_fsy,fsr);
            _unit_fogrev:=true;
            //if(uidi=UID_URadar)and(rld_t>rld_a)then _fog_sr((uo_x div fog_cw)-vid_fsx,(uo_y div fog_cw)-vid_fsy,fsr);
         end;
      end;
end;

procedure _unit_painsnd(pu:PTUnit);
begin
   with pu^ do
   begin
      case uidi of
       UID_LostSoul,
       UID_Demon,
       UID_Cacodemon,
       UID_Baron,
       UID_Cyberdemon,
       UID_Mastermind,
       UID_Arachnotron : PlaySND(snd_dpain ,pu);
       UID_ArchVile    : PlaySND(snd_arch_p,pu);
       UID_Pain        : PlaySND(snd_pain_p,pu);
       UID_Revenant,
       UID_Imp,
       UID_ZEngineer,
       UID_ZFormer,
       UID_ZSergant,
       UID_ZCommando,
       UID_ZBomber,
       UID_ZMajor,
       UID_ZBFG        : PlaySND(snd_z_p   ,pu);
       UID_Mancubus    : PlaySND(snd_man_p ,pu);
       end;
   end;
end;

procedure _uac_rocketl_eff(pu:PTUnit);
begin
   with pu^ do
   begin
      _effect_add(vx,vy-15,vy+10,EID_Exp2);
      if(playeri=HPlayer)then PlaySND(snd_exp,pu);
   end;
end;

{$ENDIF}

procedure _unit_correctcoords(pu:PTUnit);
begin;
   with pu^ do
   begin
      if(x<1     )then x:=1;
      if(y<1     )then y:=1;
      if(x>map_mw)then x:=map_mw;
      if(y>map_mw)then y:=map_mw;
   end;
end;

function _unit_flyup(pu:PTUnit;z:integer):boolean;
var st:integer;
begin
   _unit_flyup:=false;
  { with pu^ do
    if(shadow<>z)then
    begin
       st:=z-shadow;
       if(abs(st)<=2)then
       begin
          shadow:=z;
          if(st<0)then _unit_flyup:=true;
          exit;
       end
       else
       begin
          st:=sign(st)*2;
          inc(shadow,st);
       end;
       if(OnlySVCode)then
       begin
          if(uo_y=y)then dec(uo_y,st);
          dec(y ,st);
          dec(vy,st);
       end;
    end;  }
end;

procedure _unit_movevis(pu:PTUnit);
begin
   with pu^ do
    if(vx<>x)or(vy<>y)then
     if(speed<=0)or(inapc>0)then
     begin
        vstp:=0;
        vx  :=x;
        vy  :=y;
     end
     else
     begin
        if(vstp=0)then vstp:=UnitStepNum;
        inc(vx,(x-vx) div vstp);
        inc(vy,(y-vy) div vstp);
        dec(vstp,1);
     end;
end;
 {
procedure _unit_uradar(pu:PTUnit);
begin
   with pu^ do
    if(bld)then
     if(rld_t=0)then
     begin
        rld_t:=radar_time;
        {$IFDEF _FULLGAME}
        if(onlySVCode)and(player^.team=_players[HPlayer].team)then PlaySND(snd_radar,nil);
        {$ENDIF}
     end;
end;   }

function _unit_grbcol(tx,ty,tr:integer;pl,buid:byte;doodc:boolean):byte;
var u,dx,dy:integer;
   bl:boolean;
begin
   if(pl<=MaxPlayers)
   then bl:=false
   else bl:=true;
   _unit_grbcol:=0;

   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
     if(hits>0)and(speed=0)and(uf=uf_ground)and(inapc=0)then
      if(dist(x,y,tx,ty)<(tr+_r))then
      begin
         _unit_grbcol:=1;
         break;
      end
      else
       if(bl=false)then
        if(_isbuilding)and(bld)and(_isbuilder)and(playeri=pl)then
        begin
           if(buid>0)then
            if not (buid in uid^.ups_builder)then continue;
           if(dist(x,y,tx,ty)<srng)then bl:=true;
        end;

   if(_unit_grbcol=0)then
   begin
      if(bl=false)and(pl<=MaxPlayers)then
      begin
         _unit_grbcol:=2;
         exit;
      end;

      if(g_mode=gm_ct)then
       for u:=1 to MaxCPoints do
        with g_cpt_pl[u] do
         if(dist(tx,ty,px,py)<base_r)then
         begin
            _unit_grbcol:=2;
            exit;
         end;

      if(doodc=false)then exit;

      dec(tr,bld_dec_mr);

      dx:=(tx div dcw); if(dx<0)then dx:=0;if(dx>dcn)then dx:=dcn;
      dy:=(ty div dcw); if(dy<0)then dy:=0;if(dy>dcn)then dy:=dcn;

      with map_dcell[dx,dy] do
       for u:=1 to n do
        with l[u-1]^ do
         if(r>0)and(t>0)then
          if(dist(x,y,tx,ty)<(tr+r))then
          begin
             _unit_grbcol:=1;
             break;
          end;
   end;
end;

procedure _unit_def(pu:PTUnit);
begin
   with pu^ do
   begin
      inapc    := 0;
      anim     := 0;
      uo_id    := ua_amove;
      uo_tar   := 0;
      rld      := 0;
      pains    := 0;
      dir      := 270;
      order    := 0;
      wanim    := false;
      a_tar1   := 0;
      a_tar1d  := 32000;
      {alrm_x   := 0;
      alrm_y   := 0;
      alrm_r   := 32000;
      alrm_b   := false; }

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      //_unit_mmcoords(pu);
      //_unit_sfog    (pu);
      {$ENDIF}
   end;
end;

procedure _unit_done_inc_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder)then inc(n_builders,1);
      if(_isbarrack)then
      begin
         inc(n_barracks,1);
         if(buff[ub_advanced]>0)
         then inc(uprodm,2)
         else inc(uprodm,1);
      end;
      if(_issmith  )then
      begin
         inc(n_smiths  ,1);
         if(buff[ub_advanced]>0)
         then inc(pprodm,2)
         else inc(pprodm,1);
      end;
   end;
end;
procedure _unit_done_dec_cntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder)then dec(n_builders,1);
      if(_isbarrack)then
      begin
         dec(n_barracks,1);
         if(buff[ub_advanced]>0)
         then dec(uprodm,2)
         else dec(uprodm,1);
      end;
      if(_issmith  )then
      begin
         dec(n_smiths  ,1);
         if(buff[ub_advanced]>0)
         then dec(pprodm,2)
         else dec(pprodm,1);
      end;
   end;
end;

procedure _unit_inc_cntrs(pu:PTUnit;ubld:boolean);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      inc(army,1);
      inc(ucl_e[_isbuilding,_ucl],1);
      inc(ucl_c[_isbuilding],1);

      inc(uid_e[uidi],1);

      if(ubld)then
      begin
         buff[ub_born]:=fr_fps;
         bld := true;
         if(uid_x[uidi            ]=0)then uid_x[uidi            ]:=_lcu;
         if(ucl_x[_isbuilding,_ucl]=0)then ucl_x[_isbuilding,_ucl]:=_lcu;
         inc(ucl_eb[_isbuilding,_ucl],1);
         inc(uid_eb[uidi            ],1);
         inc(menerg,_generg);
         inc(cenerg,_generg);
         _unit_done_inc_cntrs(pu);
      end
      else
      begin
         bld := false;
         hits:= 1;
      end;
   end;
end;

procedure _unit_add(ux,uy:integer;ui,pl:byte;ubld:boolean);
var m,i:integer;
begin
   with _players[pl] do
   begin
      _lcu :=0;
      _lcup:=@_units[_lcu];
      if(ui=0)then exit;
      i:=MaxPlayerUnits*pl+1;
      m:=i+MaxPlayerUnits;
      while(i<m)do
      begin
         with _units[i] do
          if(hits<=dead_hits)then
          begin
             _lcu :=i;
             _lcup:=@_units[i];
             break;
          end;
         inc(i,1);
      end;

      FillChar(_lcup^,SizeOf(TUnit),0);
      if(_lcu>0)then
       with _lcup^ do
       begin
          uclord  :=_lcu mod _uclord_p;

          x       := ux;
          y       := uy;
          uidi    := ui;
          playeri := pl;
          player  :=@_players[playeri];
          vx      := x;
          vy      := y;
          uo_x    := x;
          uo_y    := y;
          uo_bx   := -1;
          uo_by   := -1;
          mv_x    := x;
          mv_y    := y;
          sel     := false;
          apcc    := 0;
          unum    := _lcu;
          FillChar(buff,sizeof(buff),0);
          FillChar(vsnt,SizeOf(vsnt),0);
          FillChar(vsni,SizeOf(vsni),0);

          _unit_def      (_lcup);
          _unit_apUID    (_lcup);
          _unit_inc_cntrs(_lcup,ubld);
       end;
   end;
end;

procedure _unit_startb(bx,by:integer;buid,bp:byte);
begin
   if(build_b<bx)and(bx<map_b1)and(build_b<by)and(by<map_b1)then
    if(_uid_cndt(@_players[bp],buid)=false)then
     with _players[bp] do
      if(_unit_grbcol(bx,by,_uids[buid]._r,bp,buid,true)=0)then
      begin
         _unit_add(bx,by,buid,bp,false);
         if(_lcu>0)then
         begin
            {$IFDEF _FULLGAME}
            if(bp=HPlayer)then PlaySND(snd_build[race],nil);
            if(_warpten=false)then
            {$ENDIF}
            bld_r:=fr_fps;
            dec(cenerg,_uids[buid]._renerg);
         end;
      end;
end;


//////   Start unit prod
//
function _unit_straining_p(pu:PTUnit;puid:byte;pn:integer):boolean;
begin
   _unit_straining_p:=false;
   if(puid<255)then
    with pu^ do
    with uid^ do
     if(uprod_r[pn]=0)and(bld)and(_isbarrack)and(_isbuilding)then
      if(puid in ups_units)and(_uid_cndt(player,puid)=false)then
       with player^ do
       begin
          inc(uproda,1);
          inc(uprodc[_uids[puid]._ucl],1);
          inc(uprodu[ puid],1);
          dec(cenerg,_uids[puid]._renerg);
          uprod_u[pn]:=puid;
          uprod_r[pn]:=_tprod;

          _unit_straining_p:=true;
       end;
end;
function _unit_straining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_straining:=true;

   for i:=0 to MaxUnitProds do
   begin
      if(i>0)then
       if(pu^.buff[ub_advanced]<=0)then break;

      if(_unit_straining_p(pu,puid,i))then exit;
   end;

   _unit_straining:=false;
end;
/// Stop unit prod
function _unit_ctraining_p(pu:PTUnit;puid:byte;pn:integer):boolean;
begin
   _unit_ctraining_p:=false;
   with pu^ do
   with uid^ do
    if(uprod_r[pn]>0)and(bld)and(_isbarrack)and(_isbuilding)then
     if(puid=255)or(puid=uprod_u[pn])then
      with player^ do
      begin
         puid:=uprod_u[pn];

         dec(uproda,1);
         dec(uprodc[_uids[puid]._ucl],1);
         dec(uprodu[ puid],1);
         inc(cenerg,_uids[puid]._renerg);
         uprod_r[pn]:=0;

         _unit_ctraining_p:=true;
      end;
end;
function _unit_ctraining(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_ctraining:=true;

   for i:=MaxUnitProds downto 0 do
    if(_unit_ctraining_p(pu,puid,i))and(puid<255)then exit;

   _unit_ctraining:=false;
end;


//////   Start upgrade production
//
function _unit_supgrade_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   _unit_supgrade_p:=false;
   if(upid<255)then
    with pu^ do
    with uid^ do
     if(pprod_r[pn]=0)and(bld)and(_issmith)and(_isbuilding)then
      if(_upid_cndt(player,upid)=false)then
       with player^ do
       with _upids[upid] do
       begin
          inc(pproda,1);
          inc(pprodu[upid],1);
          dec(cenerg,_up_renerg);
          pprod_r[pn]:=_up_time;
          pprod_u[pn]:=upid;

          _unit_supgrade_p:=true;
       end;
end;
function _unit_supgrade(pu:PTUnit;upid:integer):boolean;
var i:byte;
begin
   _unit_supgrade:=true;

   for i:=0 to MaxUnitProds do
   begin
      if(i>0)then
       if(pu^.buff[ub_advanced]<=0)then break;

      if(_unit_supgrade_p(pu,upid,i))then exit;
   end;

   _unit_supgrade:=false;
end;
function _unit_cupgrade_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   _unit_cupgrade_p:=false;
   with pu^ do
   with uid^ do
    if(pprod_r[pn]>0)and(bld)and(_issmith)and(_isbuilding)then
     if(upid=255)or(upid=pprod_u[pn])then
      with player^ do
      begin
         upid:=pprod_u[pn];

         dec(pproda,1);
         dec(pprodu[upid],1);
         inc(cenerg,_upids[upid]._up_renerg);
         pprod_r[pn]:=0;

         _unit_cupgrade_p:=true;
       end;
end;
function _unit_cupgrade(pu:PTUnit;puid:byte):boolean;
var i:byte;
begin
   _unit_cupgrade:=true;

   for i:=MaxUnitProds downto 0 do
    if(_unit_cupgrade_p(pu,puid,i))and(puid<255)then exit;

   _unit_cupgrade:=false;
end;

procedure _unit_inc_selc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      inc(ucl_s [_isbuilding,_ucl],1);
      inc(ucl_cs[_isbuilding     ],1);
      inc(uid_s [uidi],1);
      if(_isbuilder)then inc(s_builders,1);
      if(_isbarrack)then inc(s_barracks,1);
      if(_issmith  )then inc(s_smiths  ,1);
   end;
end;
procedure _unit_dec_selc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      dec(ucl_s [_isbuilding,_ucl],1);
      dec(ucl_cs[_isbuilding     ],1);
      dec(uid_s [uidi],1);
      if(_isbuilder)then dec(s_builders,1);
      if(_isbarrack)then dec(s_barracks,1);
      if(_issmith  )then dec(s_smiths  ,1);
   end;
end;

procedure _unit_desel(pu:PTUnit);
begin
   with pu^ do
   begin
      if(sel)then _unit_dec_selc(pu);
      sel:=false;
   end;
end;

procedure _unit_dec_Kcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      _unit_desel(pu);

      if(bld=false)
      then inc(cenerg,_uids[uidi]._renerg)
      else
      begin
         _unit_ctraining(pu,255);
         _unit_cupgrade (pu,255);

         dec(ucl_eb[_isbuilding,_ucl],1);
         dec(uid_eb[uidi],1);
         dec(menerg,_generg);
         dec(cenerg,_generg);

         _unit_done_dec_cntrs(pu);
      end;

      if(ucl_x[_isbuilding,_ucl]=unum)then ucl_x[_isbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure _unit_dec_Rcntrs(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      dec(army,1);
      dec(ucl_e[_isbuilding,_ucl],1);
      dec(ucl_c[_isbuilding     ],1);
      dec(uid_e[uidi],1);
   end;
end;


{
function _unit_chktar(uu,tu:PTUnit;utd:integer;teams:boolean):boolean;
begin
   _unit_chktar:=false;

   if(tu^.hits<=dead_hits)
   or(tu^.buff[ub_notarget]>0)
   //or(tu^.buff[ub_invuln  ]>0)
   or(tu^.inapc>0)
   then exit;

   if(teams=false)then
   begin
      if(_uvision(uu^.player^.team,tu,false)=false)then exit;
   end;

   if(tu^.hits<=0)then
   begin
      if(tu^.hits<idead_hits)then exit;
      case uu^.uidi of
      UID_ArchVile :if(uu^.buff[ub_advanced]=0)or(tu^.buff[ub_resur]>0)or not(tu^.uidi in arch_res)or(teams=false)or(tu^.hits>-vid_fps)then exit;
      UID_LostSoul :if(uu^.buff[ub_advanced]=0)or(tu^.buff[ub_resur]>0)or not(tu^.uidi in marines )then exit;
      else
        exit;
      end;
   end
   else
     if(teams)then
      if(uu^.uidi in [UID_Medic,UID_Engineer])then
      begin
         if(tu^.buff[ub_pain]>0)or(tu^.hits>=tu^.mhits)then exit;
         case uu^.uidi of
         UID_Medic    : begin
                           if(tu^.mech)or(uu^.inapc>0)then exit;
                           if(uu^.uidi=UID_Medic)and(tu^.uidi=UID_Medic)and(uu<>tu)then exit;
                        end;
         UID_Engineer : begin
                           if(0<uu^.inapc)and(uu^.inapc<=MaxUnits)then
                            if(tu<>@_units[uu^.inapc])then exit;
                           if(tu^.mech=false)or(tu^.bld=false)or(tu^.uidi=UID_HEye)then exit;
                        end;
         end;
      end
      else exit;

   if(uu^.uidi in [UID_UCommandCenter,UID_HCommandCenter])then
    if(uu^.uf=uf_ground)or(tu^.uf>uf_ground)then exit;

   if(tu^.uf=uf_fly)then
   begin
      if(uu^.uidi in [UID_Demon,
                     UID_UMine,
                     UID_ZEngineer])then exit;
   end;

   if(tu^.uidi in [UID_Mancubus,UID_Arachnotron])and(tu^.uidi=uu^.uidi)then exit;

   if(uu^.uidi in [UID_Bomber,UID_ZBomber,UID_Tank])then
    if(utd<=rocket_sr)or(tu^.uf>uf_ground)then exit;

   _unit_chktar:=true;
end;

function _unit_melee(uu,tu:PTUnit;teams:boolean):boolean;
begin
   _unit_melee:=true;

   case uu^.uidi of
   UID_Demon,
   UID_LostSoul,
   UID_ZEngineer : exit;
   UID_Imp,
   UID_Cacodemon,
   UID_Baron,
   UID_Revenant  : if(uu^.uidi=tu^.uidi)then exit;
   UID_Medic,
   UID_Engineer,
   UID_ArchVile  : if(teams)then exit;
   end;

   _unit_melee:=false;
end;

function _canattack(pu:PTUnit):boolean;
begin
   _canattack:=false;
   with pu^ do
   begin
      if not(uidi in whocanattack)then exit;

      if(isbuild)then
      begin
         if(bld=false)then exit;
      end
      else
        case mech of
        false: if(buff[ub_pain ]>0)
               or(buff[ub_toxin]>0)
               or(buff[ub_gear ]>0)then exit;
        true : if(buff[ub_gear ]>0)
               or(buff[ub_toxin]>0)then exit;
        end;

      if(inapc>0)then
       if(_units[inapc].uidi<>UID_APC)or(_units[inapc].inapc>0)then exit;

      _canattack:=true;
   end;
end;

function _unit_target(uu,tu:PTUnit;td:integer;voobshe:boolean):byte;
var
melee,
teams:boolean;
md   :integer;
begin
   _unit_target:=0;

   teams:=uu^.player^.team=tu^.player^.team;
   if(_unit_chktar(uu,tu,td,teams))then
   begin
      melee:=_unit_melee(uu,tu,teams);

      if(melee)then
      begin
        if(uu^.uf>uf_ground)
        then md:=td-(uu^.r+tu^.r)
        else md:=td-(uu^.r+tu^.r+uu^.speed);
        case uu^.uidi of
        UID_Engineer,
        UID_Medic   : dec(md,32);
        end;
      end
      else
        if(uu^.arf>-1)and(uu^.uf=uf_ground)and(tu^.uf=uf_fly)
        then md:=td-uu^.arf
        else md:=td-uu^.ar;

      if(md<=0)then
      begin
         if(melee)
         then _unit_target:=3
         else _unit_target:=2;
      end
      else
        if(uu^.speed>0)and(melee)then
         if(voobshe)
         then _unit_target:=1
         else
           if(td<=uu^.sr)then _unit_target:=1;
   end;
end;


function _itcanapc(uu,tu:PTUnit):boolean;
begin
   _itcanapc:=false;
   if(tu^.uf>uf_ground)then exit;
   if((uu^.apcm-uu^.apcc)>=tu^.apcs)then
    if(tu^.uidi in uu^.uid^.ups_apc)then _itcanapc:=true;
end;

function _move2uotar(uu,tu:PTUnit;td:integer):boolean;
begin
   _move2uotar:=true;
   if(tu^.uidi=UID_HTeleport)then exit;
   _move2uotar:=(tu^.x<>tu^.uo_x)or(tu^.y<>tu^.uo_y)or(td>uu^.sr);
   dec(td,uu^.r+tu^.r);
   if(td<=-melee_r)then _move2uotar:=false;
   if(tu^.playeri=uu^.playeri)then
    if(_itcanapc(tu,uu))then
    begin
       _move2uotar:=true;
       if(tu^.uf>uf_ground)and(tu^.uo_tar=0)then
       begin
          tu^.uo_x:=uu^.x;
          tu^.uo_y:=uu^.y;
       end;
    end;
end;

procedure _teleport_rld(tu:PTUnit;ur:integer);
begin
   with tu^ do
    with player^ do
     if(upgr[upgr_5bld] in [0..3])then rld_t:=max2(1,ur-((ur div 4)*upgr[upgr_5bld]));
end;

procedure _unit_teleport(pu:PTUnit;tx,ty:integer);
begin
   with pu^ do
   begin
      if(tx<0)then tx:=0;
      if(ty<0)then ty:=0;
      if(tx>map_mw)then tx:=map_mw;
      if(ty>map_mw)then ty:=map_mw;
      {$IFDEF _FULLGAME}
      if _nhp3(vx,vy,@_players[HPlayer])
      or _nhp3(tx,ty,@_players[HPlayer]) then PlaySND(snd_teleport,nil);
      _effect_add(vx,vy,vy+map_flydpth[uf]+1,EID_Teleport);
      _effect_add(tx,ty,ty+map_flydpth[uf]+1,EID_Teleport);
      {$ENDIF}
      buff[ub_pain   ]:=vid_hfps;
      buff[ub_teleeff]:=vid_fps;
      x   :=tx;
      y   :=ty;
      vx  :=x;
      vy  :=y;
      uo_x:=x;
      uo_y:=y;
      uo_tar:=0;
      _unit_correctcoords(pu);
      {$IFDEF _FULLGAME}
      _unit_mmcoords(pu);
      _unit_sfog(pu);
      {$ENDIF}
   end;
end;  }

procedure _unit_counters(pu:PTUnit);
var i : byte;
begin
   with pu^ do
   begin
      for i:=0 to _ubuffs do
       if(buff[i]<_bufinf)then
        if(buff[i]>0)then
        begin
           dec(buff[i],1);
           {if(i=ub_stopafa)and(OnlySVCode)then
            if(bld)and(speed>0)and(tar1=0)then
             if(buff[i]=0)then
              if(x<>uo_x)or(y<>uo_y)then dir:=p_dir(x,y,uo_x,uo_y);}
        end
        else
          if(buff[i]<0)then inc(buff[i],1);

      for i:=0 to MaxPlayers do
      begin
         if(0<vsnt[i])and(vsnt[i]<_bufinf)then dec(vsnt[i],1);
         if(0<vsni[i])and(vsni[i]<_bufinf)then dec(vsni[i],1);
      end;

      if(onlySVCode)then
      begin
         {
         or(uidi in whocanattack)then
         if(rld_t>0)then dec(rld_t,1); }

         for i:=0 to MaxUnitProds do
         begin
            if(uprod_r[i]>0)then dec(uprod_r[i],1);
            if(pprod_r[i]>0)then dec(pprod_r[i],1);
         end;
      end;
   end;
end;


procedure _udetect(uu,tu:PTUnit;ud:integer);
var td:integer;
begin
   with uu^ do
   begin
      {if(tu^.uidi=UID_URadar)and(tu^.rld_t>tu^.rld_a)then
      begin
         td:=dist2(x,y,tu^.uo_x,tu^.uo_y);
         if(td>ud)then td:=ud;
      end
      else} td:=ud;

      if(td<=(tu^.srng+uid^._r))then
      begin
         if(buff[ub_invis]=0)
         then _addtoint(@vsnt[tu^.player^.team],vistime)
         else
           if(tu^.buff[ub_detect]>0)and(tu^.bld)then
           begin
              _addtoint(@vsnt[tu^.player^.team],vistime);
              _addtoint(@vsni[tu^.player^.team],vistime);
           end;
      end;
   end;
end;

{
procedure _pain_lost(pu:PTUnit;tx,ty:integer);
begin
  with pu^ do
   with player^ do
    begin
       if((army+uproda)>=MaxPlayerUnits)or((playeri=0)and(g_mode=gm_inv)and(army>=g_inv_mn))
       then _lcu:=0
       else
         if(OnlySVCode)
         then _unit_add(tx,ty,UID_LostSoul,playeri,true)
         else exit;
       if(_lcu>0)then
       begin
          _lcup^.dir   :=dir;
          _lcup^.tar1  :=tar1;
          _lcup^.tar1d :=tar1d;
          _lcup^.uo_id :=uo_id;
          _lcup^.uo_tar:=uo_tar;
          if(tar1>0)then
          begin
             _lcup^.uo_x  :=_units[tar1].x;
             _lcup^.uo_y  :=_units[tar1].y;
          end
          else
           if(uo_x<>x)or(uo_y<>y)then
           begin
              _lcup^.uo_x  :=uo_x;
              _lcup^.uo_y  :=uo_y;
           end;
          _lcup^.buff[ub_advanced]:=buff[ub_advanced];
          //_lcup^.buff[ub_born    ]:=0;
          {$IFDEF _FULLGAME}
          if(_nhp3(x,y,player))then _unit_createsound(UID_LostSoul);
          {$ENDIF}
       end
       else
       begin
          {$IFDEF _FULLGAME}
          _effect_add(tx,ty,ty+map_flydpth[uf]+1,UID_LostSoul);
          PlaySND(snd_pexp,pu);
          {$ENDIF}
       end;
    end;
end;

procedure _pain_action(pu:PTUnit);
var dd,tx,ty:integer;
begin
   with pu^ do
   begin
      dd:=((dir+23) mod 360) div 45;
      tx:=x+dir_stepX[dd]*15;
      ty:=y+dir_stepY[dd]*15;

      _pain_lost(pu,tx,ty);
   end;
end;   }

function _canmove(pu:PTUnit):boolean;
begin
   with pu^ do
   begin
      _canmove:=false;

      if(onlySVCode=false)and(speed>0)then
      begin
         _canmove:=(x<>uo_x)or(y<>uo_y);
         exit;
      end;

      if(speed=0)or(buff[ub_stopafa]>0)then exit;

      case uidi of
        UID_Flyer,
        UID_Terminator,
        UID_Tank,
        UID_UTransport,
        UID_APC,
        UID_FAPC : if(buff[ub_gear ]>0)
                   or(buff[ub_toxin]>0) then exit;
        UID_UCommandCenter,
        UID_HCommandCenter: if(buff[ub_clcast]>0)then exit;
      else
        if(buff[ub_pain ]>0)
        or(buff[ub_toxin]>0)
        or(buff[ub_gear ]>0)then exit;
      end;

      _canmove:=true;
   end;
end;

procedure _unit_turn(pu:PTUnit);
begin
   with pu^ do
    if(_canmove(pu))then
     if not(uidi in slowturn)then dir:=p_dir(x,y,uo_x,uo_y);
end;
   {
procedure _unit_upgr(pu:PTUnit);
var tt:integer;
begin
   with pu^ do
    with player^ do
    begin
       if(isbuild)and(bld=false)then exit;
       if(hits<=0)then exit;

       if(_uclord_c=_uclord)then
       begin
          if(onlySVCode)then
          begin
             if(g_mode=gm_inv)and(playeri=0)then solid:=false;

             if(upgr[upgr_invuln]>0)then buff[ub_invuln]:=vid_fps;

             if(buff[ub_advanced]=0)then
              case uidi of
                UID_HTeleport       : if(g_addon=false)then buff[ub_advanced]:=_bufinf;
                UID_UVehicleFactory : if(upgr[upgr_6bld]>0)then buff[ub_advanced]:=_bufinf;
              end;
          end;

          if(buff[ub_detect]=0)then
           if(upgr[upgr_vision]>0)then
            case uidi of
            UID_URadar,
            UID_UMine    : buff[ub_detect]:=_bufinf;
            end;

          if(buff[ub_advanced]=0)then
          begin
             if(uidi=UID_HTeleport)then
              if(upgr[upgr_revtele]>0)then buff[ub_advanced]:=_bufinf;
          end;
       end;
       if(_uregen_c=_uclord)then
       begin
          if(onlySVCode)then
          begin
             if(race=r_hell)and(hits<mhits)and(buff[ub_pain]=0)and(uidi<>UID_HEye)then
             begin
                case isbuild of
                false: if(upgr[upgr_regen ]>0)then inc(hits,upgr[upgr_regen ]);
                true : if(g_addon=false)
                       then inc(hits,2)
                       else
                         if(upgr[upgr_bldrep]>0)then inc(hits,upgr[upgr_bldrep]);    //
                end;
                if(hits>mhits)then hits:=mhits;
             end;
          end;
       end;

       case uidi of
         UID_HCommandCenter,
         UID_UCommandCenter,
         UID_HKeep :  begin
                         tt:=upgr[upgr_mainr];
                         if(tt>2)then tt:=2;
                         tt:=base_rA[tt];
                         if(sr<>tt)then
                         begin
                            sr:=tt;
                            {$IFDEF _FULLGAME} _unit_fsrclc(pu);{$ENDIF}
                         end;

                         tt:=upgr[upgr_bldenrg];
                         if(tt>4)then tt:=4;
                         tt:=builder_enrg[tt];
                         if(generg<>tt)then
                         begin
                            if(onlySVCode)then inc(menerg,tt-generg);
                            generg:=tt;
                         end;
                      end;

         UID_UMine  :  buff[ub_invis]:=_bufinf;
         UID_ZEngineer,
         UID_Commando:buff[ub_invis]:=buff[ub_advanced];
         UID_Demon :  begin
                         buff[ub_invis]:=buff[ub_advanced];

                         if(upgr[upgr_pinkspd]>0)then
                         begin
                            speed:=20;
                            anims:=18;
                            rld_r:=35;
                            rld_a:=18;
                         end
                         else
                         begin
                            speed:=14;
                            anims:=15;
                            rld_r:=60;
                            rld_a:=30;
                         end;
                      end;
         UID_Imp    : if(buff[ub_advanced]<=0)then
                      begin
                         rld_r :=vid_fps;
                         rld_a:=rld_r-20;
                      end
                      else
                      begin
                         rld_r:=vid_fps-20;
                         rld_a:=rld_r-15;
                      end;

         UID_URadar : begin
                         tt:=upgr[upgr_5bld];
                         if(tt>5)then tt:=5;
                         rld_a:=radar_rlda[tt];
                         tt:=radar_rsg[tt];
                         if(sr<>tt)then
                         begin
                            sr:=tt;
                            {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
                         end;
                      end;
         UID_HEye:    begin
                         tt:=upgr[upgr_vision];
                         if(tt>5)then tt:=5;
                         tt:=eye_rsg[tt];
                         if(sr<>tt)then
                         begin
                            sr:=tt;
                            {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
                         end;
                      end;

         UID_Tank,
         UID_Revenant:
                      if(buff[ub_advanced]>0)
                      then ar:=325
                      else ar:=250;
         UID_Arachnotron:
                      if(buff[ub_advanced]>0)
                      then arf:=350
                      else arf:=ar;

         UID_APC:     if(buff[ub_advanced]>0)
                      then apcm:=6
                      else apcm:=4;
         UID_FAPC:    if(buff[ub_advanced]>0)
                      then apcm:=14
                      else apcm:=10;
         UID_ZBFG,
         UID_ZBomber,
         UID_ZCommando,
         UID_ZFormer,
         UID_Cacodemon,
         UID_Bomber,
         UID_BFG:
                      begin
                         if(buff[ub_advanced]>0)
                         then tt:=275
                         else tt:=250;

                         if(sr<>tt)then
                         begin
                            sr:=tt;
                            ar:=tt;
                            {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
                         end;
                      end;

         UID_Cyberdemon,
         UID_Mastermind:
                      begin
                         if(buff[ub_advanced]>0)
                         then tt:=300
                         else tt:=250;

                         if(sr<>tt)then
                         begin
                            sr:=tt;
                            ar:=tt;
                            {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
                         end;
                      end;

         UID_HTower,
         UID_HTotem,
         UID_UTurret,
         UID_UPTurret,
         UID_URTurret:if(sr<>towers_sr[upgr[upgr_towers]])then
                      begin
                         sr :=towers_sr[upgr[upgr_towers]];
                         ar :=sr;
                         arf:=(ar div 5)*4;
                         {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
                      end;
       end;

       case uidi of
         UID_HTotem,
         UID_HEye   : begin
                         buff[ub_invis]:=0;
                         if(g_addon)then
                         begin
                            if(upgr[upgr_totminv]>0)then buff[ub_invis]:=_bufinf;
                         end
                         else
                            if(upgr[upgr_vision ]>2)then buff[ub_invis]:=_bufinf;
                      end;
         UID_Major,
         UID_ZMajor : begin
                         if(buff[ub_advanced]>0)and(buff[ub_cast]>0)then
                         begin
                            uf   :=uf_fly;
                            speed:=13;
                         end
                         else
                         begin
                            uf   :=uf_ground;
                            speed:=9;
                         end;
                      end;
       end;

       if(buff[ub_advanced]>0)then
       begin
          if(uidi in [UID_UCommandCenter,UID_HCommandCenter])then
           if(buff[ub_clcast]>0)then
           begin
              uo_y:=y;
              vy  :=y;
              shadow:=uaccc_fly-buff[ub_clcast]
           end
           else shadow:=uaccc_fly;

          if(uidi=UID_UMine)then
           if(sr<250)then
           begin
              sr:=250;
              {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
           end;
       end
       else
       begin
          if(uidi in [UID_UCommandCenter,UID_HCommandCenter])then shadow:=buff[ub_clcast];

          if(G_Addon=false)then
           if(uidi=UID_Baron)then buff[ub_advanced]:=_bufinf;

          if(uidi=UID_UMine)then
           if(sr>100)then
           begin
              sr:=100;
              {$IFDEF _FULLGAME}_unit_fsrclc(pu);{$ENDIF}
           end;
       end;
    end;
end;
   }


