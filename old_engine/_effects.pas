
procedure _click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure _effect_add(ex,ey,ed:integer; ee:byte);
var e:integer;
begin
   if(_menu=false)and(_draw)then
    for e:=1 to vid_mvs do
     with _effects[e] do
      if(t=0)and(t2=0)then
      begin
         x :=ex;
         y :=ey;
         d :=ed;

         t :=0;
         t2:=0;

         {case ee of

         end;}

         {case e of
           UID_Pain      : begin t:=47; anl:=37; ans:= 8; end;
           UID_LostSoul  : begin t:=47; anl:=28; ans:= 8; end;
           MID_Flyer     : begin t:=15; anl:=3;  ans:= 4; end;
           MID_SShot,
           MID_SSShot,
           MID_Bullet,
           MID_Bulletx2,
           MID_TBullet,
           MID_MBullet,
           MID_Imp,
           MID_Cacodemon,
           MID_Baron     : begin t:=31; anl:=3;  ans:= 8; end;
           UID_HEye,
           EID_BFG       : begin t:=31; anl:=3;  ans:=-8; end;
           EID_BExp      : begin t:=41; anl:=5;  ans:=-7; end;
           EID_BBExp     : begin t:=62; anl:=8;  ans:=-7; end;
           EID_HUpgr     : begin t:=65; anl:=5;  ans:=-11;end;
           EID_Teleport  : begin t:=65; anl:=5;  ans:=-11;end;
           MID_YPlasma,
           MID_BPlasma   : begin t:=23; anl:=5;  ans:=5  ;end;
           MID_Revenant,
           MID_RevenantS : begin t:=23; anl:=10; ans:=8  ;end;
           EID_Blood,
           MID_HRocket,
           MID_Granade,
           MID_Tank,
           MID_Mancubus,
           EID_Exp       : begin t:=23; anl:=2; ans:=-8 ;end;
           EID_Exp2      : begin t:=39; anl:=4; ans:=-8 ;end;
           MID_BFG       : begin t:=44; anl:=5; ans:= 8 ;end;
           EID_HKT_h,
           EID_HKT_s     : t:=60;
           eid_db_h0,
           eid_db_h1,
           eid_db_u0,
           eid_db_u1     : begin t:=1; t2:=dead_time;    end;
           EID_Gavno     : begin t:=63; anl:=7; ans:=-8;t2:=dead_time; end;
           EID_ArchFire  : begin t:=57; anl:=7; ans:= 8 ;end;
           EID_HMU,
           EID_HCC,
           EID_HAMU
                         : t:=fr_fps;
         else
           t:=0;
         end;   }

        break;
     end;
end;

procedure _effectsCycle(draw,noanim:boolean);
var ei,ea,
 alpha:integer;
   spr:PTMWSprite;
   msk:cardinal;
begin
   for ei:=1 to vid_mvs do
    with _effects[ei] do
     if(t>0)or(t2>0)then
     begin
        alpha:=255;
        msk  :=0;

        {ea:=0;
        if(ans<>0)then
        begin
           ea:=t div abs(ans);
           if(ans<0)then
           begin
              if(ea>anl)then ea:=anl;
           end
           else
             if(ea>anl)
             then ea:=0
             else ea:=anl-ea;
        end;}

        spr:=@spr_dummy;

        {case e of
        UID_LostSoul   : spr:=@spr_lostsoul[ea];
        UID_Pain       : spr:=@spr_pain    [ea];
        MID_Flyer      : spr:=@spr_u_p3    [ea];
        MID_SShot,
        MID_SSShot,
        MID_Bullet,
        MID_Bulletx2,
        MID_TBullet,
        MID_MBullet    : spr:=@spr_u_p1    [ea];
        MID_Imp        : spr:=@spr_h_p0    [ea];
        MID_Cacodemon  : spr:=@spr_h_p1    [ea];
        MID_Baron      : spr:=@spr_h_p2    [ea];
        EID_BFG        : spr:=@spr_eff_bfg [ea];
        UID_HEye       : spr:=@spr_h_p2    [ea];
        EID_BExp       : spr:=@spr_eff_eb  [ea]; // 0 .. 5   40
        EID_BBExp      : spr:=@spr_eff_ebb [ea]; // 0 .. 8   62
        EID_HUpgr      : begin
                          spr:=@spr_eff_tel[ea]; // 0 .. 5   65
                          msk:=c_ared;
                         end;
        EID_Teleport   : spr:=@spr_eff_tel [ea]; // 0 .. 5   65
        MID_YPlasma    : spr:=@spr_h_p7    [ea];
        MID_BPlasma    : spr:=@spr_u_p0    [ea];
        MID_Revenant,
        MID_RevenantS  : spr:=@spr_h_p4    [ea];
        MID_HRocket,
        MID_Granade,
        MID_Tank,
        MID_Mancubus,
        EID_Exp        : spr:=@spr_eff_exp [ea]; // 0 .. 2   23
        EID_Exp2       : spr:=@spr_eff_exp2[ea]; // 0 .. 4   39
        MID_BFG        : spr:=@spr_u_p2[5-(t div 8)];
        EID_HKT_h      : begin spr:=@spr_HKeep[3]; alpha:=t*4;    end;
        EID_HKT_s      : begin spr:=@spr_HKeep[3]; alpha:=255-t*4;end;
        EID_db_h0      : spr:=@spr_db_h0;
        EID_db_h1      : spr:=@spr_db_h1;
        EID_db_u0      : spr:=@spr_db_u0;
        EID_db_u1      : spr:=@spr_db_u1;
        EID_HMU        : begin spr:=@spr_UMilitaryUnit [3]; alpha:=t*4; end;
        EID_HAMU       : begin spr:=@spr_UAMilitaryUnit[3]; alpha:=t*4; end;
        EID_HCC        : begin spr:=@spr_UCommandCenter[3]; alpha:=t*4; end;
        EID_Gavno      : spr:=@spr_eff_g[ea]; // 0 .. 7   63
        EID_Blood      : begin spr:=@spr_blood[ea]; if(t>15)and(onlyspr=false)then inc(y,1); end;
        EID_ArchFire   : spr:=@spr_h_p6[ea];
        else
          spr:=@spr_dummy;
        end;}


        if(noanim=false)then
        begin
           if(t>0)
           then dec(t,1)
           else
             if(t2>0)then
             begin
                dec(t2,1);
                if(t2<255)then alpha:=t2;
             end;
        end;

        if(draw)then
         if(_rectvis(x,y,spr^.hw,spr^.hh,0))then
          _sl_add_eff(x,y,d,msk,spr,alpha);
     end;
end;



