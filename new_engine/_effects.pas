
procedure _click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   if(G_Status>0)then exit;
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure _effect_add(ex,ey,ed:integer; ee:byte);
var e:integer;
begin
   if(_menu=false)then
    for e:=1 to vid_mvs do
     with _effects[e] do
      if(t=0)and(t2=0)then
      begin
         x :=ex;
         y :=ey;
         e :=ee;
         d :=ed;
         t :=0;
         t2:=0;

         case e of
           EID_DPain,
           EID_DLostSoul  : t:=47;

           MID_SShot,
           MID_SSShot,
           MID_Bullet,
           MID_Bulletx2,
           MID_TBullet,
           MID_Imp,
           MID_Cacodemon,
           MID_Baron,
           EID_BFG       : t:=31;
           EID_BExp      : t:=41;
           EID_BBExp     : t:=62;
           EID_HUpgr,
           EID_Teleport  : t:=65;
           MID_YPlasma,
           MID_BPlasma,
           MID_Revenant,
           EID_Blood,
           MID_HRocket,
           MID_Granade,
           MID_Mancubus,
           EID_Exp       : t:=23;
           MID_URocket,
           EID_Exp2      : t:=39;
           MID_bfg       : t :=44;
           EID_HKT_h,
           EID_HKT_s     : t:=60;
           EID_Gavno     : begin t:=63; t2:=dead_time; end;
           eid_db_h0,
           eid_db_h1,
           eid_db_u0,
           eid_db_u1     : begin t:=1; t2:=dead_time; end;
           EID_ArchFire  : t :=57;
           UID_HMilitaryUnit : t:=vid_fps;
         else
           t:=0;
         end;

        break;
     end;
end;

procedure _effect_uadd(pu:PTUnit;ee:byte;d:integer=-32000);
begin
   with (pu^) do
   begin
      if(d=-32000)then d:=vy+map_flydpth[uf]+1;
      _effect_add(vx,vy,d,ee);
   end;
end;

procedure _effectsCycle(draw:boolean);
var ei,alpha:integer;
  spr:PTUSprite;
  msk:cardinal;
begin
   for ei:=1 to vid_mvs do
    with _effects[ei] do
     if(t>0)or(t2>0)then
     begin
        alpha:=255;
        msk:=0;

        case e of
          EID_DPain      : spr:=@spr_pain[37-(t div 8)];
          EID_DLostSoul  : spr:=@spr_lostsoul[28-(t div 8)];

          EID_BFG        : spr:=@spr_eff_bfg [t div 8 ]; // 0 .. 3   31
          EID_BExp       : spr:=@spr_eff_eb  [t div 7 ]; // 0 .. 5   40
          EID_BBExp      : spr:=@spr_eff_ebb [t div 7 ]; // 0 .. 8   62
          EID_HUpgr      : begin
                              spr:=@spr_eff_tel [t div 11]; // 0 .. 5   65
                              msk:=c_ared;
                           end;
          EID_Teleport   : spr:=@spr_eff_tel [t div 11]; // 0 .. 5   65
          MID_HRocket,
          MID_Granade,
          MID_Mancubus,
          EID_Exp        : spr:=@spr_eff_exp [t div 8 ]; // 0 .. 2   23
          MID_URocket,
          EID_Exp2       : spr:=@spr_eff_exp2[t div 8 ]; // 0 .. 4   39
          EID_Gavno      : spr:=@spr_eff_g[t div 8 ]; // 0 .. 7   63
          EID_db_h0      : spr:=@spr_db_h0;
          EID_db_h1      : spr:=@spr_db_h1;
          EID_db_u0      : spr:=@spr_db_u0;
          EID_db_u1      : spr:=@spr_db_u1;
          MID_bfg        : spr:=@spr_u_p2[5-(t div 8)];
          EID_HKT_h      : begin spr:=@spr_HKeep[3]; alpha:=t*4;    end;
          EID_HKT_s      : begin spr:=@spr_HKeep[3]; alpha:=255-t*4;end;
          EID_Blood      : begin spr:=@spr_blood[2-(t div 8)]; if(t>15)then inc(y,1); end;
          MID_SShot,
          MID_SSShot,
          MID_Bullet,
          MID_Bulletx2,
          MID_TBullet    : spr:=@spr_u_p1[3 -(t div 8)];
          MID_Imp        : spr:=@spr_h_p0[3 -(t div 8)];
          MID_Cacodemon  : spr:=@spr_h_p1[3 -(t div 8)];
          MID_Baron      : spr:=@spr_h_p2[3 -(t div 8)];
          MID_YPlasma    : spr:=@spr_h_p7[5 -(t div 5)];
          MID_BPlasma    : spr:=@spr_u_p0[5 -(t div 5)];
          MID_Revenant   : spr:=@spr_h_p4[10-(t div 8)];
          EID_ArchFire   : spr:=@spr_h_p6[7 -(t div 8)];
          EID_HMilitaryUnit : begin spr:=@spr_UMilitaryUnit[3]; alpha:=t*4; end;
        else
          spr:=spr_pDummy;
        end;

        if(G_Status=0)then
         if(t>0)
         then dec(t,1)
         else
           if(t2>0)then
           begin
              dec(t2,1);
              if(t2<255)then alpha:=t2;
           end;

        if(draw)then
         if((vid_vx-spr^.hw)<x)and(x<(vid_vx+vid_mw+spr^.hw))and
           ((vid_vy-spr^.hh)<y)and(y<(vid_vy+ui_panely+spr^.hh))then
           _sl_add(x-spr^.hw, y-spr^.hh,d,0,0,msk,false,spr^.surf,alpha,0,0,0,0,'',0,0);
     end;
end;



