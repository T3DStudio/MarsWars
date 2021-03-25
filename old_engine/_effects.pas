
procedure _click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure _effect_add(ex,ey,ed:integer; ee:byte);
var e:integer;

procedure _setEff(sm:PTMWSModel;ans,si,ei,sms,it:integer;revanim:boolean);
var sc:integer;
begin
   with _effects[e] do
   begin
      x :=ex;
      y :=ey;
      d :=ed;

      smodel:=sm;

      anim_last_i_t:= it;
      anim_smstate := sms;
      anim_step    := ans;

      anim_i       := si;
      if(ei<0)
      then sc := smodel^.sn
      else
        if(ei<smodel^.sn)
        then sc := smodel^.sn-ei
        else sc := smodel^.sn;

      anim_last_i:=(sc*anim_step)-1;

      if(revanim)then
      begin
         sc:=anim_i;
         anim_i:=anim_last_i;
         anim_last_i:=sc;
      end;
   end;
end;

begin
   if(_menu=false)and(_draw)then
    for e:=1 to vid_mvs do
     with _effects[e] do
      if(anim_last_i_t=0)then
      begin

         case ee of
UID_Pain          : _setEff(@spr_pain      ,7 ,0 ,32 ,sms_death,-1       ,false);
UID_LostSoul      : _setEff(@spr_lostsoul  ,7 ,0 ,23 ,sms_death,-1       ,false);

EID_Teleport      : _setEff(@spr_eff_tel   ,10,0 ,-1 ,sms_death,-1       ,true );
EID_Gavno         : _setEff(@spr_eff_g     ,7 ,0 ,-1 ,sms_death,dead_time,true );

EID_db_h0         : _setEff(@spr_db_h0     ,1 ,0 ,0  ,sms_death,dead_time,false);
EID_db_h1         : _setEff(@spr_db_h1     ,1 ,0 ,0  ,sms_death,dead_time,false);
EID_db_u0         : _setEff(@spr_db_u0     ,1 ,0 ,0  ,sms_death,dead_time,false);
EID_db_u1         : _setEff(@spr_db_u1     ,1 ,0 ,0  ,sms_death,dead_time,false);
         else
           exit;
         end;

         if(anim_step=0)or(smodel=nil)then
         begin
            anim_last_i_t:=0;
            break;
         end;


         {case e of

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

procedure effects_sprites(noanim,draw:boolean);
var ei,ea,
 alpha:integer;
   spr:PTMWSprite;
   msk:cardinal;
begin
   for ei:=1 to vid_mvs do
    with _effects[ei] do
     if(anim_last_i_t<>0)then
     begin
        alpha:=255;
        msk  :=0;

        spr:=@spr_dummy;

        if(anim_last_i_t>=0)then alpha:=min2(255,anim_last_i_t);

        if(noanim=false)then
        begin
           if(anim_i<anim_last_i)
           then inc(anim_i,1)
           else
             if(anim_i>anim_last_i)
             then dec(anim_i,1)
             else
             begin
                if(anim_last_i_t>0)then dec(anim_last_i_t,1);
                if(anim_last_i_t<0)then anim_last_i_t:=0;
             end;
        end;

        spr:=_sm2s(smodel,anim_smstate,270,anim_i div anim_step);

        if(draw)then
         if(_rectvis(x,y,spr^.hw,spr^.hh,0))then
          _sl_add_eff(x,y,d,msk,spr,alpha);
     end;
end;


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

{
anim_i,
anim_last,
anim_as,
anim_lastt,
anim_smstate
}
