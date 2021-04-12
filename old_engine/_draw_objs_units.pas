
procedure _unit_minimap(pu:PTUnit);
begin
  if(vid_rtui=0)and(_menu=false)and(_draw)then
   with pu^ do
   with uid^ do
    if(uid^._isbuilding)
    then filledCircleColor(r_minimap,mmx,mmy,mmr,p_color(player^.pnum))
    else pixelColor       (r_minimap,mmx,mmy,    p_color(player^.pnum));
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

function _fog_cscr(x,y,r:integer):boolean;
begin
   _fog_cscr:=((vid_fsx-r)<=x)and(x<=(vid_fex+r))
           and((vid_fsy-r)<=y)and(y<=(vid_fey+r));
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
         if(_ability=uab_radar)and(rld>radar_btime)then _fog_sr((uo_x div fog_cw)-vid_fsx,(uo_y div fog_cw)-vid_fsy,fsr);
      end;
      end;
end;


procedure _unit_uiprodcnts(pu:PTUnit;pn:integer);
var i,t:byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbarrack)then
      begin
         for t:=1 to 255 do
          if(t in uid^.ups_units)then inc(ui_prod_units[t],1);   //?????????????????//

         if(uprod_r[pn]>0)then
         begin
            i:=uprod_u[pn];
            if(ui_units_ptime[i]=0)or(ui_units_ptime[i]>uprod_r[pn])then ui_units_ptime[i]:=uprod_r[pn];
         end;
      end;

      if(_issmith)then
      begin
         if(pprod_r[pn]>0)then
         begin
            i:=pprod_u[pn];
            //if(upgrade_mfrg[race,i])then inc(ui_upgrct[i],1);
            if(ui_first_upgr_time=0)or(pprod_r[pn]<ui_first_upgr_time)then ui_first_upgr_time:=pprod_r[pn];
            if(ui_upgr[i]=0)or(ui_upgr[i]>pprod_r[pn])then ui_upgr[i]:=pprod_r[pn];
         end;
      end;
   end;
end;

procedure _orders(x,y:integer;i:byte);
begin
   if(ui_orders_x[i]=0)then
   begin
      ui_orders_x[i]:=x;
      ui_orders_y[i]:=y;
   end
   else
   begin
      ui_orders_x[i]:=(ui_orders_x[i]+x) div 2;
      ui_orders_y[i]:=(ui_orders_y[i]+y) div 2;
   end;
   inc(ui_orders_n[i],1);
end;

procedure _ui_counters(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   if(playeri=HPlayer)and(G_Paused=0)then
   with uid^ do
   with player^ do
   begin
      if(order<10)then
      begin
         _orders(x,y,order);
         ui_orders_uids[order,_isbuilding]:=ui_orders_uids[order,_isbuilding]+[uidi];
      end;

      if(speed>0)and(_attack>0)then
      begin
         inc(ui_uibtn_f2,1);
         _orders(x,y,10);
      end;

      if(_isbuilding)then
      begin
         if(bld)then
         begin
            ui_prod_builds := ui_prod_builds + uid^.ups_builder;
            if(_isbuilder)and(0<m_brush)and(m_brush<=255)and(speed=0)then
             if(m_brush in uid^.ups_builder)then
               if(_rectvis(x,y,srange,srange,0))then _addUIBuildRs(x,y,srange);

            for i:=0 to MaxUnitProds do
             if(i>0)and(buff[ub_advanced]<=0)
             then break
             else _unit_uiprodcnts(pu,i);
         end;
         if(sel)and(_UnitHaveRPoint(pu))then _sl_add_dec(uo_x,uo_y,32000,-32000,@spr_mp[_urace],255,0,0,-spr_mp[_urace].hh);
      end;

      if(bld)then
      begin
         if(rld<ui_uid_reload[uidi])or(ui_uid_reload[uidi]=0)then ui_uid_reload[uidi]:=rld;

         if(sel)then
         begin
            if(speed>0)then inc(ui_uibtn_move,1);
            if(_ability in [])then inc(ui_uibtn_action,1);
         end;
      end
      else
      begin
         inc(ui_uid_builds[uidi],1);
         inc(ui_uid_buildn      ,1);
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
         dec(animf,1);
         if(animf<=0)then
         begin
            PlaySND(un_eid_snd_foot[adv],nil);
            animf:=un_foot_anim[adv];
         end;
      end;
   end;
end;

function _EID2Spr(eid:byte):PTMWSprite;
begin
   _EID2Spr:=@spr_dummy;

   with _eids[eid] do
    if(smodel<>nil)then
     if(smodel^.sn>0)then
      _EID2Spr:=@smodel^.sl[0];
end;

procedure _unit_aspr(pu:PTUnit;noanim:boolean);
const _btnas: array[false..true] of integer = (0,vid_hBW);
var spr : PTMWSprite;
     dp,
invb,inv,t,ro,
     sh : integer;
     mc,
     rc : cardinal;
     sb : single;
b0,b2,b3: byte;
    b1  : string6;
    rct : boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      _ui_counters(pu);

      if(_unit_fogrev(pu))then
      begin
         _unit_minimap(pu);

         wanim:=false;
         if(g_paused=0)then
          if(_canmove(pu))then
           wanim:=(x<>mv_x)or(y<>mv_y)or(x<>vx)or(y<>vy);

         spr:=_unit2spr(pu);

         if(spr=pspr_dummy)then exit;

         sh:=_unit_shadowz(pu);
         inc(shadow,sign(sh-shadow));
         sh :=shadow;
         if(_rectvis(vx,vy,spr^.hw,spr^.hh,sh))then
         begin
            dp :=0;
            inv:=255;
            rc :=0;
            sb :=0;
            mc :=0;
            b0 :=0;
            b1 :='';
            b2 :=0;
            b3 :=0;
            rct:=false;
            rc :=p_color(playeri);
            ro :=0;

            if(_isbuilding)then
             if(0<m_brush)and(m_brush<=255)
             then ro:=_r
             else
             begin
                {if(sel)then
                 case uidi of
                UID_UTurret,
                UID_UPTurret,
                UID_URTurret,
                UID_HTower,
                UID_HTotem,
                UID_UMine,
                UID_HEye     : ro:=ar;
                UID_HSymbol  : if(upgr[upgr_b478tel]>0)then ro:=sr;
                 else
                 if(isbuilder)and(speed=0)then ro:=sr;
                 end;   }
             end;

            if(wanim)then _unit_foot_effects(pu);

            if((sel)and(playeri=HPlayer))
            or(k_alt>1)
            or((ui_umark_u=unum)and(vid_rtui>vid_rtuish))then
            begin
               rct:=true;
               if(buff[ub_advanced ]>0)then b1:=b1+adv_char;
               if(buff[ub_detect   ]>0)then b1:=b1+hp_detect;
               if(playeri=HPlayer)then
               begin
                  if(order>0)then b0:=order;
                  if(apcm>0)then
                  begin
                     b2:=apcm;
                     b3:=apcc;
                  end;
               end;
            end;

            if(rct)
            then sb:=hits/_mhits
            else
              case vid_uhbars of
            0: if(hits<_mhits)then sb:=hits/_mhits;
            1: sb:=hits/_mhits;
              end;

            if(buff[ub_invis ]>0 )then inv:=128;
            if(buff[ub_invuln]>10)then mc :=c_awhite;

            if(playeri=0)and(_isbuilding=false)then
             if(g_mode in [gm_inv,gm_aslt])then mc:=c_ablack;

            dp:=_udpth(pu);

            if(_isbuilding)then
             if(bld)then
             begin
                if(a_rld<=0)and(noanim=false)then
                if(uidi in [UID_UTurret,UID_UPTurret,UID_URTurret])then
                begin
                    inc(dir,_animw);
                    dir:=dir mod 360;
                end;

                if(playeri=HPlayer)then
                begin
                   for t:=0 to MaxUnitProds do
                   begin
                      if(_isbarrack)and(uprod_r[t]>0)then _sl_add(vx-_btnas[buff[ub_advanced]>0]+vid_BW*t,vy,dp,0,c_gray,0,true,@_uids [uprod_u[t]]. un_btn[_uids[uprod_u[t]]._advanced[g_addon]],255,0,(uprod_r[t] div fr_fps)+1,0,0,'',0);
                      if(_issmith  )and(pprod_r[t]>0)then _sl_add(vx-_btnas[buff[ub_advanced]>0]+vid_BW*t,vy,dp,0,c_red ,0,true,@_upids[pprod_u[t]]._up_btn                                      ,255,0,(pprod_r[t] div fr_fps)+1,0,0,'',0);
                   end;
                end;
             end
             else
              if(un_eid_bcrater>0)and(un_build_amode>0)then
              begin
                 if(un_build_amode>1)then
                 begin
                    inv :=trunc(255*hits/_mhits);
                    invb:=255-inv;
                 end
                 else invb:=255;

                 if(buff[ub_invis]>0)then invb:=invb shr 1;

                 _sl_add_eff(vx,vy+un_eid_bcrater_y,-5,0,_EID2Spr(un_eid_bcrater),invb);
              end
              else
                if(buff[ub_invis]>0)then inv:=inv shr 1;

            _sl_add(vx,vy,dp,sh,rc,mc,rct,spr,inv,sb,b0,b2,b3,b1,ro);
         end;
      end;
   end;
end;

{if(race=r_hell)then
 case uidi of
UID_HMonastery,
UID_HTotem,
UID_HAltar,
UID_HFortress,
UID_HEye : begin
              inv:=trunc(255*hits/_mhits);
              if(_r<41)
              then _sl_add_eff(vx,vy+5 ,-5,0,@spr_db_h1.sl[0],255-inv)
              else _sl_add_eff(vx,vy+10,-5,0,@spr_db_h0.sl[0],255-inv);
              if(buff[ub_invis]>0)then inv:=inv shr 1;
              dec(inv,inv shr 2);
           end;
 else
   if(hits<=127)then
   begin
      inv:=hits*2;
      if(_r<41)
      then _sl_add_eff(vx,vy+5 ,-5,0,@spr_db_h1.sl[0],255-inv)
      else _sl_add_eff(vx,vy+10,-5,0,@spr_db_h0.sl[0],255-inv);
   end
   else inv:=255;
 end; }

{ if(buff[ub_toxin]>0)then
if(mech)
then _sl_add_dec(vx, smy,dp,0,@spr_gear ,255,0, 0,-spr^.hh-spr_gear .hh-7)
else _sl_add_dec(vx, smy,dp,0,@spr_toxin,255,0, 0,-spr^.hh-spr_toxin.hh-7);
if(buff[ub_gear ]>0)then
     _sl_add_dec(vx, smy,dp,0,@spr_gear ,255,0, 0,-spr^.hh-spr_gear .hh-7);  }

{

procedure _unit_foot(pu:PTUnit);
begin
   with pu^ do
   begin
      case uidi of
        UID_Arachnotron :
              begin
                 inc(foot,1);
                 foot:=foot mod 28;
                 if(foot=0)then PlaySND(snd_ar_f,pu);
              end;
        UID_Cyberdemon :
              begin
                 inc(foot,1);
                 foot:=foot mod 30;
                 if(foot=0)then PlaySND(snd_cyberf,pu);
              end;
        UID_Mastermind :
              begin
                 inc(foot,1);
                 foot:=foot mod 22;
                 if(foot=0)then PlaySND(snd_mindf,pu);
              end;
      end;
   end;
end;

procedure _unit_vis(pu:PTUnit;nanim:boolean);
const _btnas : array[false..true] of integer = (vid_hBW,vid_BW);
var spr : PTMWSprite;
     dp,smy,
     inv,t,ro,
     sh : integer;
     mc,
     rc : cardinal;
     sb : single;
b0,b2,b3: byte;
    b1  : string6;
    rct : boolean;

begin
   with pu^ do
    if(hits>0)and(inapc=0)then
    with player^ do
     begin
        _unit_uidata(pu);

        if(_unit_fogrev(pu))then
        begin
           _unit_minimap(pu);

           if(uidi=UID_HKeep)then
            if(buff[ub_clcast]>0)then exit;

           wanim:=false;
           if(g_paused=0)then
            if(_canmove(pu))then
             wanim:=(x<>mv_x)or(y<>mv_y)or(x<>vx)or(y<>vy);

           spr:=_unit_spr(pu);
           sh :=0;
           smy:=vy;

           if(shadow>0)then
           begin
              sh:=shadow;
              if(uidi in [UID_UCommandCenter,UID_HCommandCenter])then
              begin
                 if(buff[ub_advanced]=0)
                 then dec(smy,buff[ub_clcast])
                 else inc(smy,buff[ub_clcast]);
              end;
           end;

           if ((vid_vx   -spr^.hw)<vx )and(vx <(vid_vx+vid_sw+spr^.hw))and
              ((vid_vy-sh-spr^.hh)<smy)and(smy<(vid_vy+vid_sh+spr^.hh)) then
           begin
              dp :=0;
              inv:=255;
              rc :=0;
              sb :=0;
              mc :=0;
              b0 :=0;
              b1 :='';
              b2 :=0;
              b3 :=0;
              rct:=false;
              rc :=p_color(playeri);
              ro :=0;


           end;
        end;
     end;
end;
}

procedure _unit_dspr(pu:PTUnit);
var spr:PTMWSprite;
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
        if(_rectvis(vx,vy,spr^.hw,spr^.hh,0))then
         _sl_add_dec(vx,vy,_udpth(pu),-32000,spr,mm3(0,abs(hits-fdead_hits),255),0,0,0);
    end;
end;


procedure unit_sprites(noanim:boolean);
var u:integer;
   pu:PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=@_units[u];
      with pu^ do
       if(hits>0)
       then _unit_aspr(pu,noanim)
       else _unit_dspr(pu);
   end;
end;



