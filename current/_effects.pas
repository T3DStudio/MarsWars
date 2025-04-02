
procedure effect_InitCLData;
var x:byte;
procedure setEID(sm:PTMWSModel;sms:byte);
begin
   with g_eids[x] do
   begin
      smodel      :=sm;
      anim_smstate:=sms;
   end;
end;
begin
   FillChar(g_eids,SizeOf(g_eids),0);

   for x:=0 to 255 do
   with g_eids[x] do
   begin
      anim_smstate:=sms_death;
      smodel:=spr_pdmodel;
      case x of
        UID_Pain          : setEID(@spr_pain          ,sms_death);
        UID_Phantom       : setEID(@spr_Phantom       ,sms_death);
        UID_LostSoul      : setEID(@spr_lostsoul      ,sms_death);
        UID_HEye          : setEID(@spr_h_p2          ,sms_death);

        MID_BPlasma       : setEID(@spr_u_p0          ,sms_death);
        MID_SShot,
        MID_SSShot,
        MID_Bullet,
        MID_MChaingun,
        MID_Chaingun      : setEID(@spr_u_p1          ,sms_death);
        MID_BFG           : setEID(@spr_u_p2          ,sms_death);
        MID_Flyer         : setEID(@spr_u_p3          ,sms_death);

        MID_Imp           : setEID(@spr_h_p0          ,sms_death);
        MID_Cacodemon     : setEID(@spr_h_p1          ,sms_death);
        MID_Baron         : setEID(@spr_h_p2          ,sms_death);
        MID_URocketS,
        MID_URocket,
        MID_Revenant      : setEID(@spr_h_p4          ,sms_death);
        MID_YPlasma       : setEID(@spr_h_p7          ,sms_death);

        EID_BFG           : setEID(@spr_eff_bfg       ,sms_death);

        MID_HRocket,
        MID_Granade,
        MID_Tank,
        MID_Mancubus,
        EID_Exp           : setEID(@spr_eff_exp        ,sms_death);
        EID_Exp2          : setEID(@spr_eff_exp2       ,sms_death);

        EID_Blood         : setEID(@spr_blood          ,sms_death);

        MID_ArchFire,
        EID_ArchFire      : setEID(@spr_h_p6           ,sms_death);

        EID_HLevelUp      : begin
                            setEID(@spr_eff_tel        ,sms_death);
                            smask :=c_ared;
                            end;
        EID_ULevelUp      : begin
                            setEID(@spr_eff_gtel       ,sms_death);
                            smask :=c_aaqua;
                            end;
        EID_HVision       : begin
                            setEID(@spr_eff_gtel       ,sms_death);
                            smask :=c_alime;
                            end;
        EID_Invuln        : begin
                            setEID(@spr_eff_gtel       ,sms_death);
                            smask :=c_awhite;
                            end;
        EID_Teleport      : setEID(@spr_eff_tel        ,sms_death);
        EID_Gavno         : setEID(@spr_eff_g          ,sms_death);
        MID_Mine,
        EID_BExp          : setEID(@spr_eff_eb         ,sms_death);
        MID_Blizzard,
        EID_BBExp         : setEID(@spr_eff_ebb        ,sms_death);
        EID_HKeep_H,
        EID_HKeep_S       : setEID(@spr_HKeep1          ,sms_walk );
        EID_HAKeep_H,
        EID_HAKeep_s      : setEID(@spr_HKeep2         ,sms_walk );
        EID_db_h0         : setEID(@spr_db_h0          ,sms_death);
        EID_db_h1         : setEID(@spr_db_h1          ,sms_death);
        EID_db_u0         : setEID(@spr_db_u0          ,sms_death);
        EID_db_u1         : setEID(@spr_db_u1          ,sms_death);
        UID_UGTurret      : setEID(@spr_UTurret        ,sms_build);
        UID_UATurret      : setEID(@spr_URTurret       ,sms_build);
      end;
   end;
end;

procedure click_eff(cx,cy,ca:integer;cc:cardinal);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure effect_add(ex,ey,ed:integer;ee:byte);
var e:integer;
procedure setEff(ans,si,ei,it:integer;revanim:boolean;az:integer);
var sc:integer;
    sm:PTMWSModel;
begin
   with g_effects[e] do
   begin
      x :=ex;
      y :=ey;
      d :=ed;
      z :=az;
      sm:=g_eids[ee].smodel;

      anim_last_i_t:= it;
      anim_step    := ans;

      anim_i       := si;

      if(ans>0)then
      begin
         if(ei=-1)
         then sc := sm^.sm_listn
         else
           if(ei<sm^.sm_listn)
           then sc := sm^.sm_listn-ei
           else sc := sm^.sm_listn;

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
   if(menu_state)or(G_Status<>gs_running)or(r_draw=false)or(ee=0)or(g_eids[ee].smodel=nil)then exit;

   for e:=1 to vid_MaxScreenSprites do
   with g_effects[e] do
   if(anim_last_i_t=0)then
   begin
      case ee of
//                       anin  frst  last,
//                       step  frame
UID_Pain          : setEff(9 ,0 ,32 ,-1       ,false,0 );
UID_Phantom,
UID_LostSoul      : setEff(7 ,0 ,23 ,-1       ,false,0 );
UID_HEye          : setEff(6 ,0 ,8  ,-1       ,true ,0 );

MID_BPlasma       : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_SShot,
MID_SSShot,
MID_Bullet,
MID_MChaingun,
MID_Chaingun      : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_BFG           : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Flyer         : setEff(6 ,0 ,-1 ,-1       ,false,0 );

MID_Imp           : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Cacodemon     : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Baron,//         : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_URocketS,
MID_URocket,
MID_Revenant      : setEff(7 ,0 , 8 ,-1       ,false,0 );
MID_YPlasma       : setEff(6 ,0 ,-1 ,-1       ,false,0 );

EID_BFG           : setEff(6 ,0 ,-1 ,-1       ,true ,0 );

MID_HRocket,
MID_Granade,
MID_Tank,
MID_Mancubus,
EID_Exp           : setEff(7 ,0 ,-1 ,-1       ,true ,0 );
EID_Exp2          : setEff(7 ,0 ,-1 ,-1       ,true ,0 );

EID_Blood         : setEff(6 ,0 ,-1 ,-1       ,true ,15);

MID_ArchFire,
EID_ArchFire      : setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HLevelUp,
EID_ULevelUp,
EID_HVision,
EID_Invuln,
EID_Teleport      : setEff(10,0 ,-1 ,-1       ,true ,0 );
EID_Gavno         : setEff(7 ,0 ,-1 ,dead_time,true ,0 );

MID_Mine,
EID_BExp          : setEff(5 ,0 ,-1 ,-1       ,true ,0 );
MID_Blizzard,
EID_BBExp         : setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HKeep_H,
EID_HKeep_S,
EID_HAKeep_H,
EID_HAKeep_S      : setEff(0 ,3 ,3  ,fr_fps1   ,false,0 );

UID_UGTurret,
UID_UATurret,
EID_db_h0,
EID_db_h1,
EID_db_u0,
EID_db_u1         : setEff(0 ,0 ,0  ,dead_time,false,0 );
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

procedure missile_ExplodeEffect(m:integer);
var i,o,r:byte;
begin
   with g_missiles[m] do
   with g_mids[mid] do
   if(ui_MapPointInRevealedInScreen(vx,vy))then
   begin
      o:=ms_eid_death_cnt[ms_eid_bio_death];
      r:=ms_eid_death_r  [ms_eid_bio_death];
      if(r<2)or(o<2)then
      begin
         r:=0;
         o:=1;
      end;
      for i:=1 to o do effect_add(vx-g_randomr(r),vy-g_randomr(r),SpriteDepth(vy,mfs)+100,ms_eid_death[ms_eid_bio_death]);

      if(mfe=uf_ground)and(ms_eid_decal>0)then effect_add(vx,vy,sd_liquid+vy,ms_eid_decal);

      if(ms_snd_death_ch[ms_eid_bio_death]>0)then
       if(random(ms_snd_death_ch[ms_eid_bio_death])>0)then exit;

      SoundPlayUnit(ms_snd_death[ms_eid_bio_death],nil,nil);
   end;
end;

procedure d_SpriteListAddMissiles;
var  m:integer;
   spr:PTMWTexture;
begin
   for m:=1 to MaxMissiles do
   with g_missiles[m] do
   with g_mids[mid] do
   if(vstep>0)then
   begin
      spr:=sm_SModel2MWTexture(ms_smodel,sms_stand,dir,0,nil);
      if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then SpriteListAddEffect(vx,vy,SpriteDepth(vy,mfs)+100,0,spr,255);
   end;
end;


procedure effect_teleport(vx,vy,tx,ty:integer;ukfly:boolean;eidstart,eidend:byte;snd:PTSoundSet);
begin
   if ui_MapPointInRevealedInScreen(vx,vy)
   or ui_MapPointInRevealedInScreen(tx,ty) then SoundPlayUnit(snd,nil,nil);
   effect_add(vx,vy,SpriteDepth(vy+1,ukfly),eidstart);
   effect_add(tx,ty,SpriteDepth(ty+1,ukfly),eidend  );
end;

procedure d_SpriteListAddEffects(noanim,draw:boolean);
var ei,
 alpha:integer;
   spr:PTMWTexture;
anim_stat:byte;
begin
   for ei:=1 to vid_MaxScreenSprites do
    with g_effects[ei] do
     if(anim_last_i_t<>0)then
     with g_eids[eid] do
     begin
        alpha:=255;

        spr:=@spr_dummy;

        if(anim_last_i_t>=0)then
         case eid of
EID_HKeep_H,
EID_HAKeep_H  : alpha:=anim_last_i_t*4;
EID_HKeep_S,
EID_HAKeep_S  : alpha:=255-(anim_last_i_t*4);
         else   alpha:=min2i(255,anim_last_i_t);
         end;

        if(not noanim)then
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

        if(not draw)then continue;

        if(anim_step>0)
        then spr:=sm_SModel2MWTexture(smodel,anim_smstate,270,anim_i div anim_step,@anim_stat)
        else spr:=sm_SModel2MWTexture(smodel,anim_smstate,270,anim_i              ,@anim_stat);

        if(RectInCam(x,y,spr^.hw,spr^.hh,0))then SpriteListAddEffect(x,y,d,smask,spr,alpha);
     end;
end;

