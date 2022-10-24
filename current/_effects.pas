
procedure initEffects;
var x:byte;
procedure _setEID(sm:PTMWSModel;sms:byte);
begin
   with _eids[x] do
   begin
      smodel      :=sm;
      anim_smstate:=sms;
   end;
end;
begin
   FillChar(_eids,SizeOf(_eids),0);

   for x:=0 to 255 do
   with _eids[x] do
   begin
      anim_smstate:=sms_death;
      smodel:=spr_pdmodel;
      case x of
        UID_Pain          : _setEID(@spr_pain          ,sms_death);
        UID_LostSoul      : _setEID(@spr_lostsoul      ,sms_death);
        UID_HEye          : _setEID(@spr_h_p2          ,sms_death);

        MID_BPlasma       : _setEID(@spr_u_p0          ,sms_death);
        MID_SShot,
        MID_SSShot,
        MID_Bullet,
        MID_Bulletx2,
        MID_TBullet,
        MID_MBullet       : _setEID(@spr_u_p1          ,sms_death);
        MID_BFG           : _setEID(@spr_u_p2          ,sms_death);
        MID_Flyer         : _setEID(@spr_u_p3          ,sms_death);

        EID_HAEye,
        MID_Imp           : _setEID(@spr_h_p0          ,sms_death);
        MID_Cacodemon     : _setEID(@spr_h_p1          ,sms_death);
        MID_Baron         : _setEID(@spr_h_p2          ,sms_death);
        MID_URocketS,
        MID_URocket,
        MID_Revenant,
        MID_RevenantH     : _setEID(@spr_h_p4          ,sms_death);
        MID_YPlasma       : _setEID(@spr_h_p7          ,sms_death);

        EID_BFG           : _setEID(@spr_eff_bfg       ,sms_death);

        MID_HRocket,
        MID_Granade,
        MID_Tank,
        MID_Mancubus,
        EID_Exp           : _setEID(@spr_eff_exp       ,sms_death);
        EID_Exp2          : _setEID(@spr_eff_exp2      ,sms_death);

        EID_Blood         : _setEID(@spr_blood         ,sms_death);

        EID_ArchFire      : _setEID(@spr_h_p6          ,sms_death);

        EID_HUpgr         : begin
                            _setEID(@spr_eff_tel       ,sms_death);
                            smask :=c_ared;
                            end;
        EID_Teleport      : _setEID(@spr_eff_tel       ,sms_death);
        EID_Gavno         : _setEID(@spr_eff_g         ,sms_death);
        MID_Mine,
        EID_BExp          : _setEID(@spr_eff_eb        ,sms_death);
        MID_Blizzard,
        EID_BBExp         : _setEID(@spr_eff_ebb       ,sms_death);
        EID_HKT_h,
        EID_HKT_s         : _setEID(@spr_HKeep         ,sms_walk );
        EID_HCC           : _setEID(@spr_UCommandCenter,sms_walk );
        EID_HMU           : _setEID(@spr_UMilitaryUnit ,sms_walk );
        EID_HAMU          : _setEID(@spr_UAMilitaryUnit,sms_walk );
        EID_db_h0         : _setEID(@spr_db_h0         ,sms_death);
        EID_db_h1         : _setEID(@spr_db_h1         ,sms_death);
        EID_db_u0         : _setEID(@spr_db_u0         ,sms_death);
        EID_db_u1         : _setEID(@spr_db_u1         ,sms_death);
        UID_UGTurret      : _setEID(@spr_UTurret       ,sms_build);
        UID_UATurret      : _setEID(@spr_URTurret      ,sms_build);
      end;
   end;
end;

procedure _click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure _effect_add(ex,ey,ed:integer; ee:byte);
var e:integer;

procedure _setEff(ans,si,ei,it:integer;revanim:boolean;az:integer);
var sc:integer;
    sm:PTMWSModel;
begin
   with _effects[e] do
   begin
      x :=ex;
      y :=ey;
      d :=ed;
      z :=az;
      sm:=_eids[ee].smodel;

      anim_last_i_t:= it;
      anim_step    := ans;

      anim_i       := si;

      if(ans>0)then
      begin
         if(ei=-1)
         then sc := sm^.sn
         else
           if(ei<sm^.sn)
           then sc := sm^.sn-ei
           else sc := sm^.sn;

         anim_last_i:=(sc*anim_step)-1;

         if(revanim)then
         begin
            sc:=anim_i;
            anim_i:=anim_last_i;
            anim_last_i:=sc;
         end;
      end
      else anim_last_i:=si;
   end;
end;

begin
   if(_menu)or(G_Status>gs_running)or(r_draw=false)or(ee=0)or(_eids[ee].smodel=nil)then exit;

   for e:=1 to vid_mvs do
   with _effects[e] do
   if(anim_last_i_t=0)then
   begin
      case ee of
//                       anin  frst  last,
//                       step  frame
UID_Pain          : _setEff(9 ,0 ,32 ,-1       ,false,0 );
UID_LostSoul      : _setEff(7 ,0 ,23 ,-1       ,false,0 );
EID_HAEye,
UID_HEye          : _setEff(6 ,0 ,-1 ,-1       ,true ,0 );

MID_BPlasma       : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_SShot,
MID_SSShot,
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet       : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_BFG           : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Flyer         : _setEff(6 ,0 ,-1 ,-1       ,false,0 );

MID_Imp           : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Cacodemon     : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Baron         : _setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_URocketS,
MID_URocket,
MID_Revenant,
MID_RevenantH     : _setEff(7 ,0 , 8 ,-1       ,false,0 );
MID_YPlasma       : _setEff(6 ,0 ,-1 ,-1       ,false,0 );

EID_BFG           : _setEff(6 ,0 ,-1 ,-1       ,true ,0 );

MID_HRocket,
MID_Granade,
MID_Tank,
MID_Mancubus,
EID_Exp           : _setEff(7 ,0 ,-1 ,-1       ,true ,0 );
EID_Exp2          : _setEff(7 ,0 ,-1 ,-1       ,true ,0 );

EID_Blood         : _setEff(6 ,0 ,-1 ,-1       ,true ,15);

EID_ArchFire      : _setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HUpgr,
EID_Teleport      : _setEff(10,0 ,-1 ,-1       ,true ,0 );
EID_Gavno         : _setEff(7 ,0 ,-1 ,dead_time,true ,0 );

MID_Mine,
EID_BExp          : _setEff(5 ,0 ,-1 ,-1       ,true ,0 );
MID_Blizzard,
EID_BBExp         : _setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HKT_h,
EID_HKT_s,
EID_HMU,
EID_HCC,
EID_HAMU          : _setEff(0 ,3 ,3  ,fr_fps   ,false,0 );

UID_UGTurret,
UID_UATurret,
EID_db_h0,
EID_db_h1,
EID_db_u0,
EID_db_u1         : _setEff(0 ,0 ,0  ,dead_time,false,0 );
      else exit;
      end;

      if(anim_step=0)and(anim_i<>anim_last_i)then
      begin
         anim_last_i_t:=0;
         break;
      end;

      eid:=ee;
      break;
   end;
end;

{
ms_smodel    : PTMWSModel;
ms_eid_fly_st: integer;
ms_snd_death_ch,
ms_eid_fly,
ms_eid_death : byte;
ms_snd_death : PTSoundSet;

x,y,
vx,vy,
dam,
vst,
tar,
sr,
dir,
ystep,
mtars,
ntars    : integer;
player,
mid,mf   : byte;
homing   : boolean;
}

procedure _missile_explode_effect(m:integer);
var i,o,r:byte;
begin
   with _missiles[m] do
   with _mid_effs[mid] do
   if(PointInScreenP(vx,vy,nil))then
   begin
      o:=ms_eid_death_cnt[ms_eid_bio_death];
      r:=ms_eid_death_r  [ms_eid_bio_death];
      if(r<2)or(o<2)then
      begin
         r:=0;
         o:=1;
      end;
      for i:=1 to o do _effect_add(vx-_randomr(r),vy-_randomr(r),_FlyDepth(vy,mfs)+100,ms_eid_death[ms_eid_bio_death]);

      if(ms_eid_decal>0)then _effect_add(vx,vy,-6,ms_eid_decal);

      if(ms_snd_death_ch[ms_eid_bio_death]>0)then
       if(random(ms_snd_death_ch[ms_eid_bio_death])>0)then exit;

      SoundPlayUnit(ms_snd_death[ms_eid_bio_death],nil,nil);
   end;
end;

procedure missiles_sprites(noanim,draw:boolean);
var  m:integer;
   spr:PTMWTexture;
begin
   for m:=1 to MaxMissiles do
   with _missiles[m] do
   with _mid_effs[mid] do
   if(vstep>0)then
   begin
      spr:=@spr_dummy;

      spr:=_sm2s(ms_smodel,sms_stand,dir,0,nil);

      if(draw)then
       if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then SpriteListAddEffect(vx,vy,_FlyDepth(vy,mfs)+100,0,spr,255);
   end;
end;


procedure teleport_effects(vx,vy,tx,ty:integer;ukfly:boolean;eidstart,eidend:byte;snd:PTSoundSet);
begin
   if PointInScreenP(vx,vy,nil)
   or PointInScreenP(tx,ty,nil) then SoundPlayUnit(snd,nil,nil);
   _effect_add(vx,vy,_FlyDepth(vy+1,ukfly),eidstart);
   _effect_add(tx,ty,_FlyDepth(ty+1,ukfly),eidend  );
end;

procedure effects_sprites(noanim,draw:boolean);
var ei,
 alpha:integer;
   spr:PTMWTexture;
anim_stat:byte;
begin
   for ei:=1 to vid_mvs do
    with _effects[ei] do
     if(anim_last_i_t<>0)then
     with _eids[eid] do
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
              if(z>0)then begin y+=1;z-=1;end;
              if(z<0)then begin y-=1;z+=1;end;
              if(anim_i<anim_last_i)then anim_i+=1;
              if(anim_i>anim_last_i)then anim_i-=1;
           end
           else
           begin
              if(anim_last_i_t>0)then anim_last_i_t-=1;
              if(anim_last_i_t<0)then anim_last_i_t:=0;
           end;
        end;

        if(anim_step>0)
        then spr:=_sm2s(smodel,anim_smstate,270,anim_i div anim_step,@anim_stat)
        else spr:=_sm2s(smodel,anim_smstate,270,anim_i              ,@anim_stat);

        if(draw)then
         if(RectInCam(x,y,spr^.hw,spr^.hh,0))then SpriteListAddEffect(x,y,d,smask,spr,alpha);
     end;
end;

