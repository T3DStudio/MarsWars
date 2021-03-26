
procedure _click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure _effect_add(ex,ey,ed:integer; ee:byte);
var e:integer;

procedure _setEff(sm:PTMWSModel;ans,si,ei,sms,it:integer;revanim:boolean;az:integer;amask:cardinal);
var sc:integer;
begin
   with _effects[e] do
   begin
      x :=ex;
      y :=ey;
      d :=ed;
      z :=az;

      smask :=amask;
      smodel:=sm;

      anim_last_i_t:= it;
      anim_smstate := sms;
      anim_step    := ans;

      anim_i       := si;
      if(ei=-1)
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
UID_Pain          : _setEff(@spr_pain      ,7 ,0 ,32 ,sms_death,-1       ,false,0 ,0);
UID_LostSoul      : _setEff(@spr_lostsoul  ,7 ,0 ,23 ,sms_death,-1       ,false,0 ,0);
UID_HEye          : _setEff(@spr_h_p2      ,6 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);

MID_BPlasma       : _setEff(@spr_u_p0      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_SShot,
MID_SSShot,
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet       : _setEff(@spr_u_p1      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_BFG           : _setEff(@spr_u_p2      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_Flyer         : _setEff(@spr_u_p3      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);

MID_Imp           : _setEff(@spr_h_p0      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_Cacodemon     : _setEff(@spr_h_p1      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_Baron         : _setEff(@spr_h_p2      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);
MID_Revenant,
MID_RevenantS     : _setEff(@spr_h_p4      ,7 ,0 , 8 ,sms_death,-1       ,false,0 ,0);
MID_YPlasma       : _setEff(@spr_h_p7      ,6 ,0 ,-1 ,sms_death,-1       ,false,0 ,0);

EID_BFG           : _setEff(@spr_eff_bfg   ,6 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);

MID_HRocket,
MID_Granade,
MID_Tank,
MID_Mancubus,
EID_Exp           : _setEff(@spr_eff_exp   ,7 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);
EID_Exp2          : _setEff(@spr_eff_exp2  ,7 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);

EID_Blood         : _setEff(@spr_blood     ,6 ,0 ,-1 ,sms_death,-1       ,true ,15,0);

EID_ArchFire      : _setEff(@spr_h_p6      ,6 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);

EID_HUpgr         : _setEff(@spr_eff_tel   ,10,0 ,-1 ,sms_death,-1       ,true ,0 ,c_ared);
EID_Teleport      : _setEff(@spr_eff_tel   ,10,0 ,-1 ,sms_death,-1       ,true ,0 ,0);
EID_Gavno         : _setEff(@spr_eff_g     ,7 ,0 ,-1 ,sms_death,dead_time,true ,0 ,0);

EID_BExp          : _setEff(@spr_eff_eb    ,5 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);
EID_BBExp         : _setEff(@spr_eff_ebb   ,6 ,0 ,-1 ,sms_death,-1       ,true ,0 ,0);

EID_HKT_h,
EID_HKT_s         : _setEff(@spr_HKeep     ,1 ,3 ,3  ,sms_walk ,fr_fps   ,false,0 ,0);
EID_HMU           : _setEff(@spr_UCommandCenter,1,3,3,sms_walk ,fr_fps   ,false,0 ,0);
EID_HCC           : _setEff(@spr_UMilitaryUnit ,1,3,3,sms_walk ,fr_fps   ,false,0 ,0);
EID_HAMU          : _setEff(@spr_UAMilitaryUnit,1,3,3,sms_walk ,fr_fps   ,false,0 ,0);


EID_db_h0         : _setEff(@spr_db_h0     ,1 ,0 ,0  ,sms_death,dead_time,false,0 ,0);
EID_db_h1         : _setEff(@spr_db_h1     ,1 ,0 ,0  ,sms_death,dead_time,false,0 ,0);
EID_db_u0         : _setEff(@spr_db_u0     ,1 ,0 ,0  ,sms_death,dead_time,false,0 ,0);
EID_db_u1         : _setEff(@spr_db_u1     ,1 ,0 ,0  ,sms_death,dead_time,false,0 ,0);
         else
           exit;
         end;

         if(anim_step=0)or(smodel=nil)then
         begin
            anim_last_i_t:=0;
            break;
         end;

         eid:=ee;
         break;
      end;
end;

procedure effects_sprites(noanim,draw:boolean);
var ei,
 alpha:integer;
   spr:PTMWSprite;

begin
   for ei:=1 to vid_mvs do
    with _effects[ei] do
     if(anim_last_i_t<>0)then
     begin
        alpha:=255;

        spr:=@spr_dummy;

        if(anim_last_i_t>=0)then
         case eid of
EID_HMU,
EID_HCC,
EID_HAMU,
EID_HKT_h   : alpha:=anim_last_i_t*4;
EID_HKT_s   : alpha:=255-(anim_last_i_t*4);
         else alpha:=min2(255,anim_last_i_t);
         end;

        if(noanim=false)then
        begin
           if(anim_i<>anim_last_i)then
           begin
              if(z>0)then begin inc(y,1);dec(z,1);end;
              if(z<0)then begin dec(y,1);inc(z,1);end;
              if(anim_i<anim_last_i)then inc(anim_i,1);
              if(anim_i>anim_last_i)then dec(anim_i,1);
           end
           else
           begin
              if(anim_last_i_t>0)then dec(anim_last_i_t,1);
              if(anim_last_i_t<0)then anim_last_i_t:=0;
           end;
        end;

        spr:=_sm2s(smodel,anim_smstate,270,anim_i div anim_step);

        if(draw)then
         if(_rectvis(x,y,spr^.hw,spr^.hh,0))then _sl_add_eff(x,y,d,smask,spr,alpha);
     end;
end;

