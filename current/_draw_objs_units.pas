
procedure _unit_minimap(pu:PTUnit);
begin
   if(vid_rtui=0)and(_menu=false)and(r_draw)then
    with pu^  do
    with uid^ do
     if(uid^._ukbuilding)
     then filledCircleColor(r_minimap,mmx,mmy,mmr,PlayerGetColor(player^.pnum))
     else pixelColor       (r_minimap,mmx,mmy,    PlayerGetColor(player^.pnum));
end;


function _SpriteDepth(y:integer;f:boolean):integer;
begin
   _SpriteDepth:=map_flydepths[f]+y;
end;

function _unit_SpriteDepth(pu:PTUnit):integer;
begin
   _unit_SpriteDepth:=0;
   with pu^ do
    case uidi of
UID_UPortal,
UID_HTeleport,
UID_HSymbol,
UID_HASymbol,
UID_HAltar,
UID_UMine     : _unit_SpriteDepth:=sd_tcraters+vy;
    else
      if(uid^._ukbuilding)and(bld=false)
      then _unit_SpriteDepth:=sd_brocks+vy
      else
        if(hits>0)or(buff[ub_resur]>0)
        then _unit_SpriteDepth:=_SpriteDepth(vy,ukfly or (zfall>0))
        else _unit_SpriteDepth:=_SpriteDepth(vy,ukfly);
    end;
end;


procedure _fog_sr(x,y,r:integer);
var iy,i:integer;
procedure _sf(tx,ty:integer);
begin if(0<=tx)and(0<=ty)and(tx<=vid_fog_vfw)and(ty<=vid_fog_vfh)then vid_fog_grid[tx,ty]:=2;end;
begin
   if(r<0    )then r:=0;
   if(r>MFogM)then r:=MFogM;
   for i:=0 to r do
    for iy:=0 to _RX2Y[r,i] do
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

function _fog_cscr(x,y,r:integer):boolean;
begin
   _fog_cscr:=((vid_fog_sx-r)<=x)and(x<=(vid_fog_ex+r))
           and((vid_fog_sy-r)<=y)and(y<=(vid_fog_ey+r));
end;

procedure _unit_sfog(pu:PTUnit);
begin
   with pu^ do
   begin
      fx :=round(x/fog_cw);
      fy :=round(y/fog_cw);
   end;
end;

function UnitVisionRange(pu:PTUnit):byte;
begin
   UnitVisionRange:=0;
   if((HPlayer=0)and(rpls_state>=rpl_rhead))
   or(PlayerObserver(@_players[HPlayer]))
   then UnitVisionRange:=2
   else
     with pu^ do
      if(_uvision(_players[HPlayer].team,pu,false))then
       if(player^.team=_players[HPlayer].team)
       then UnitVisionRange:=2
       else UnitVisionRange:=1;
end;

function _unit_fogrev(pu:PTUnit):boolean;
begin
   _unit_fogrev:=false;
   with pu^     do
   with uid^    do
   with player^ do
    if(rpls_fog=false)
    then _unit_fogrev:=true
    else
      case UnitVisionRange(pu) of
    1:begin
         if(_fog_cscr(fx,fy,_fr))then _fog_sr(fx-vid_fog_sx,fy-vid_fog_sy,_fr);
         _unit_fogrev:=true;
      end;
    2:begin
         if(_fog_cscr(fx,fy,fsr))then _fog_sr(fx-vid_fog_sx,fy-vid_fog_sy,fsr);
         _unit_fogrev:=true;
         if(_ability=uab_radar)and(rld>radar_btime)then _fog_sr((uo_x div fog_cw)-vid_fog_sx,(uo_y div fog_cw)-vid_fog_sy,fsr);
      end;
      end;
end;


procedure ui_ProductionCounters(pu:PTUnit;pn:integer);
var i,t:byte;
    pcurrent:boolean;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(_isbarrack)then
      begin
         pcurrent:=(s_barracks<=0)or(sel);
         if(pcurrent)then ui_uprod_max+=1;

         for t:=1 to 255 do
          if(pcurrent)then
           if(t in ups_units)then ui_uprod_uid_max[t]+=1;     //possible productions count of each unit type     +byte(buff[ub_advanced]>0)

         if(uprod_r[pn]>0)then
         begin
            if(pcurrent)then ui_uprod_cur+=1;
            i:=uprod_u[pn];
            if(ui_uprod_first      <=0)or(ui_uprod_first      >uprod_r[pn])then ui_uprod_first      :=uprod_r[pn];
            if(ui_uprod_uid_time[i]<=0)or(ui_uprod_uid_time[i]>uprod_r[pn])then ui_uprod_uid_time[i]:=uprod_r[pn];
         end;
      end;

      if(_issmith)then
      begin
         for t:=1 to 255 do
          if(s_smiths<=0)or(sel)then   // and(s_smiths>0)
           if(t in ups_upgrades)then ui_pprod_max[t]+=1;   //possible productions count of each upgrade type      +byte(buff[ub_advanced]>0)

         if(pprod_r[pn]>0)then
         begin
            i:=pprod_u[pn];
            if(ui_pprod_first  <=0)or(pprod_r[pn]  <ui_pprod_first)then ui_pprod_first  :=pprod_r[pn];
            if(ui_pprod_time[i]<=0)or(ui_pprod_time[i]>pprod_r[pn])then ui_pprod_time[i]:=pprod_r[pn];
         end;
      end;
   end;
end;

procedure ui_IncOrderCounter(x,y:integer;i:byte);
begin
   if(i>MaxUnitGroups)then exit;
   if(ui_orders_n[i]=0)then
   begin
      ui_orders_x[i]:=x;
      ui_orders_y[i]:=y;
   end
   else
     if (abs(x-ui_orders_x[i])<vid_vw)
     and(abs(y-ui_orders_y[i])<vid_vh)then
     begin
        ui_orders_x[i]:=(ui_orders_x[i]+x) div 2;
        ui_orders_y[i]:=(ui_orders_y[i]+y) div 2;
     end;
   ui_orders_n[i]+=1;
end;

procedure ui_counters(pu:PTUnit);
var i:byte;
    t:integer;
begin
   with pu^ do
   if(playeri=HPlayer)and(G_Status=gs_running)then
   with uid^ do
   with player^ do
   begin
      if(group<MaxUnitGroups)then
      begin
         ui_IncOrderCounter(x,y,group);
         ui_orders_uids[group,_ukbuilding]:=ui_orders_uids[group,_ukbuilding]+[uidi];
      end;

      if(UnitF2Select(pu))then ui_IncOrderCounter(x,y,MaxUnitGroups); // all battle units

      if(_ukbuilding)then
      begin
         if(bld)then
         begin
            if(n_builders>0)and(isbuildarea)then
            begin
               ui_bprod_possible+=ups_builder;
               if(0<m_brush)and(m_brush<=255)then
                if(m_brush in ups_builder)then
                 if(RectInCam(x,y,srange,srange,0))then UnitsInfoAddCircle(x,y,srange,ui_blink_color1[r_blink_colorb]);
            end;

            for i:=0 to MaxUnitProdsI do
             if(i>0)and(buff[ub_advanced]<=0)
             then break
             else ui_ProductionCounters(pu,i);
         end;
         if(sel)and(_UnitHaveRPoint(pu^.uidi))then SpriteListAddMarker(uo_x,uo_y,@spr_mp[_urace]);
      end;

      if(bld)then
      begin
         if(rld<ui_uid_reload[uidi])or(ui_uid_reload[uidi]<0)then ui_uid_reload[uidi]:=rld;
         if(rld<ui_ucl_reload[_ucl])or(ui_ucl_reload[_ucl]<0)then ui_ucl_reload[_ucl]:=rld;

         if(sel)then
         begin
            if(speed>0)then ui_uibtn_move+=1;
            if((_ability>0)and(_canability(pu)))
            or(apcc>0)
            or((buff[ub_advanced]<=0)and(_isbarrack or _issmith)and(uid_x[uid_race_9bld[race]]>0))then ui_uibtn_action+=1;
         end;
      end
      else
      begin
         t:=min2(_btime,((_mhits-hits+_bstep) div _bstep) div 2);
         if(t>0)then
         begin
            if(ui_bprod_ucl_time[_ucl]<=0)
            or(ui_bprod_ucl_time[_ucl]> t)then ui_bprod_ucl_time[_ucl]:=t;
            if(ui_bprod_first<=0)
            or(ui_bprod_first> t)then ui_bprod_first:=t;
         end;
         ui_bprod_uid_count[uidi]+=1;
         ui_bprod_ucl_count[_ucl]+=1;
         ui_bprod_all       +=1;
      end;
   end;
end;

procedure _unit_foot_effects(pu:PTUnit);
var adv:boolean;
begin
   with pu^ do
   begin
      adv:=buff[ub_advanced]>0;
      with uid^ do
      if(un_foot_anim[adv]>0)then
      begin
         animf-=1;
         if(animf<=0)then
         begin
            SoundPlayUnit(un_eid_snd_foot[adv],nil,nil);
            animf:=un_foot_anim[adv];
         end;
      end;
   end;
end;

function _EID2Spr(eid:byte):PTMWTexture;
begin
   _EID2Spr:=@spr_dummy;

   with _eids[eid] do
    if(smodel<>nil)then
     if(smodel^.sn>0)then
      _EID2Spr:=@smodel^.sl[0];
end;

procedure _unit_level_string(pu:PTUnit);
var i,
al,wl,sl:integer;
   atset:TSoB;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(rld>0)
      then lvlstr_r:=tc_aqua+i2s(it2s(rld))
      else lvlstr_r:='';

      // weapon/attack
      wl      :=0;
      atset   :=[];
      for i:=0 to MaxUnitWeapons do
       with _a_weap[i] do
        if(aw_rld>0)and(aw_dupgr>0)and not(aw_dupgr in atset)then
        begin
           wl+=upgr[aw_dupgr];
           atset+=[aw_dupgr];
        end;
      lvlstr_w:=tc_red+i2s6(wl);

      // armor
      al:=upgr[_upgr_armor];
      if(_ukbuilding)
      then al+=upgr[upgr_race_build_armor[_urace]]
      else
        if(_ukmech)
        then al+=upgr[upgr_race_mech_armor[_urace]]
        else al+=upgr[upgr_race_bio_armor [_urace]];
      lvlstr_a:=tc_lime+i2s6(al);

      // other
      sl:=upgr[_upgr_regen]+upgr[_upgr_srange];
      if(_ukbuilding)
      then sl+=integer(upgr[upgr_race_build_regen[_urace]])
      else
        if(_ukmech)
        then sl+=integer(upgr[upgr_race_mech_regen [_urace]]+upgr[upgr_race_mech_mspeed[_urace]])
        else
        begin
           sl+=integer(upgr[upgr_race_mech_mspeed[_urace]]+upgr[upgr_race_bio_mspeed [_urace]]);
           if(_urace=r_hell)then sl+=upgr[upgr_hell_pains];
        end;
      lvlstr_s:=tc_yellow+i2s6(sl);
   end;
end;

procedure _unit_alive_sprite(pu:PTUnit;noanim:boolean);
const _btnas: array[false..true] of integer = (0,vid_hBW);
var spr : PTMWTexture;
depth,
alphab,
alpha,t : integer;
aura    : cardinal;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      ui_counters(pu);

      if(_unit_fogrev(pu))then
      begin
         _unit_minimap(pu);

         if(_ability=uab_hkeeptele)then
          if(buff[ub_clcast]>0)then exit;

         wanim:=false;
         if(G_Status=gs_running)then
          if(_canmove(pu))then
           wanim:=(x<>mv_x)or(y<>mv_y)or(x<>vx)or(y<>vy);

         spr:=_unit2spr(pu);

         if(spr=pspr_dummy)then exit;

         depth:=_unit_shadowz(pu)-shadow;
         t:=sign(depth);
         if(depth<-1)then t*=2;
         shadow+=t;

         if(RectInCam(vx,vy,spr^.hw,spr^.hh,shadow))then
         begin
            if(cycle_order=_cycle_order)and(noanim=false)
            then _unit_level_string(pu);

            depth:=_unit_SpriteDepth(pu);
            alpha:=255;
            aura :=0;

            if(wanim)then _unit_foot_effects(pu);

            UnitsInfoAddUnit(pu,un_smodel[buff[ub_advanced]>0]);

            if(buff[ub_invis ]>0 )then alpha:=128;

            if(buff[ub_invuln]>fr_6hfps)
            then aura:=c_awhite
            else
              if(playeri=0)and(not _ukbuilding)then
               if(g_mode in [gm_invasion])then aura:=c_ablack;

            if(_ukbuilding)then
             if(bld)then
             begin
                if(a_rld<=0)and(noanim=false)then
                 if(uidi in [UID_UGTurret,UID_UATurret])then
                 begin
                    dir+=_animw;
                    dir:=dir mod 360;
                 end;

                if(playeri=HPlayer)then
                begin
                   for t:=0 to MaxUnitProdsI do
                   begin
                      if(_isbarrack)and(uprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[buff[ub_advanced]>0]+vid_BW*t,vy,c_lime  ,@_uids [uprod_u[t]]. un_btn[upgr[_uids[uprod_u[t]]._upgr_bornadv]>0],i2s(it2s(uprod_r[t])),'','','','');
                      if(_issmith  )and(pprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[buff[ub_advanced]>0]+vid_BW*t,vy,c_yellow,@_upids[pprod_u[t]]._up_btn                                         ,i2s(it2s(pprod_r[t])),'','','','');
                   end;
                end;

                case uidi of
UID_UCommandCenter: if(upgr[upgr_uac_ccturr]>0)then SpriteListAddUnit(vx+3,vy-65,depth,0,0,0,@spr_ptur,alpha);
                end;
             end
             else
              if(un_eid_bcrater>0)and(un_build_amode>0)then
              begin
                 if(un_build_amode>1)then
                 begin
                    alpha :=trunc(255*hits/_mhits);
                    alphab:=255-alpha;
                 end
                 else alphab:=255;

                 if(buff[ub_invis]>0)then alphab:=alphab shr 1;

                 SpriteListAddEffect(vx,vy+un_eid_bcrater_y,sd_liquid+un_eid_bcrater_y+y,0,_EID2Spr(un_eid_bcrater),alphab);
              end
              else
                if(buff[ub_invis]>0)then alpha:=alpha shr 1;

            SpriteListAddUnit(vx,vy,depth,shadow,ShadowColor(PlayerGetColor(playeri)),aura,spr,alpha);
         end;
      end;
   end;
end;

procedure _unit_dead_sprite(pu:PTUnit);
var spr:PTMWTexture;
begin
   with pu^ do
   with uid^ do
   with player^ do
    if(hits>dead_hits)then
    begin
       if(hits<fdead_hits)then exit;

       spr:=_unit2spr(pu);

       if(spr=pspr_dummy)then exit;

       if(_unit_fogrev(pu))then
        if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then
         SpriteListAddDoodad(vx,vy,_unit_SpriteDepth(pu),-32000,spr,mm3(0,abs(hits-fdead_hits) div 4,255),0,0);
    end;
end;

procedure unit_sprites(noanim:boolean);
var u:integer;
pu,tu:PTUnit;
begin
   for u:=0 to 255 do
   begin
      ui_uid_reload[u]:=-1;
      ui_ucl_reload[u]:=-1;
   end;
   FillChar(ui_bprod_uid_count,SizeOf(ui_bprod_uid_count),0);
   FillChar(ui_bprod_ucl_count,SizeOf(ui_bprod_ucl_count),0);
   FillChar(ui_bprod_ucl_time ,SizeOf(ui_bprod_ucl_time ),0);
   FillChar(ui_uprod_uid_time ,SizeOf(ui_uprod_uid_time ),0);
   FillChar(ui_uprod_uid_max  ,SizeOf(ui_uprod_uid_max  ),0);
   FillChar(ui_pprod_max      ,SizeOf(ui_pprod_max      ),0);
   FillChar(ui_orders_uids    ,SizeOf(ui_orders_uids    ),0);
   FillChar(ui_pprod_time     ,SizeOf(ui_pprod_time     ),0);
   FillChar(ui_units_inapc    ,SizeOf(ui_units_inapc    ),0);
   FillChar(ui_orders_n       ,SizeOf(ui_orders_n       ),0);
   FillChar(ui_orders_x       ,SizeOf(ui_orders_x       ),0);
   FillChar(ui_orders_y       ,SizeOf(ui_orders_y       ),0);
   ui_uprod_max      :=0;
   ui_uprod_cur      :=0;
   ui_uprod_first    :=0;
   ui_pprod_first    :=0;
   ui_uibtn_action   :=0;
   ui_uibtn_move     :=0;
   ui_bprod_possible :=[];
   ui_bprod_first    :=0;
   ui_bprod_all      :=0;

   if(ui_umark_t>0)then begin ui_umark_t-=1;if(ui_umark_t=0)then ui_umark_u:=0;end;
   for u:=1 to MaxUnits do
   begin
      pu:=@_units[u];
      with pu^ do
       if(_IsUnitRange(inapc,@tu))then
       begin
          if(tu^.sel)and(G_Status=gs_running)and(playeri=HPlayer)then ui_units_inapc[uidi]+=1;
       end
       else
         if(hits<=0)
         then _unit_dead_sprite(pu)
         else _unit_alive_sprite(pu,noanim);
   end;
end;



