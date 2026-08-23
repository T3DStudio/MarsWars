
procedure initEffects;
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
        UID_Pain          : setEID(@spr_pain           ,sms_death);
        UID_Phantom       : setEID(@spr_Phantom        ,sms_death);
        UID_LostSoul      : setEID(@spr_lostsoul       ,sms_death);
        UID_HEye          : setEID(@spr_h_p2           ,sms_death);

        MID_BPlasma       : setEID(@spr_u_p0           ,sms_death);
        MID_SShot,
        MID_SSShot,
        MID_Bullet,
        MID_SChaingun,
        MID_Chaingun      : setEID(@spr_u_p1           ,sms_death);
        MID_BFG           : setEID(@spr_u_p2           ,sms_death);
        MID_Flyer         : setEID(@spr_u_p3           ,sms_death);

        MID_Imp           : setEID(@spr_h_p0           ,sms_death);
        MID_Cacodemon     : setEID(@spr_h_p1           ,sms_death);
        MID_Baron         : setEID(@spr_h_p2           ,sms_death);
        MID_URocketS,
        MID_URocket,
        MID_Revenant      : setEID(@spr_h_p4           ,sms_death);
        MID_YPlasma       : setEID(@spr_h_p7           ,sms_death);

        EID_BFG           : setEID(@spr_eff_bfg        ,sms_death);

        MID_CyberRocket,
        MID_Tank,
        MID_Mancubus,
        EID_Exp1          : setEID(@spr_eff_exp1       ,sms_death);
        EID_Exp2          : setEID(@spr_eff_exp2       ,sms_death);
        MID_Granade,
        EID_Exp3          : setEID(@spr_eff_exp3       ,sms_death);

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
        EID_UnitCaptured  : begin
                            setEID(@spr_eff_gtel       ,sms_death);
                            smask :=c_ablue;
                            end;
        EID_PowerUp       : begin
                            setEID(@spr_eff_gtel       ,sms_death);
                            smask :=c_awhite;
                            end;
        EID_Teleport      : setEID(@spr_eff_tel        ,sms_death);
        EID_InfantryGibs  : setEID(@spr_eff_g          ,sms_death);
        MID_Blizzard,
        EID_BExp          : setEID(@spr_eff_eb         ,sms_death);
        EID_BBExp         : setEID(@spr_eff_ebb        ,sms_death);
        EID_HKeep_H,
        EID_HKeep_S       : setEID(@spr_HKeep          ,sms_walk );
        EID_HAKeep_H,
        EID_HAKeep_s      : setEID(@spr_HAKeep         ,sms_walk );
        EID_db_h0         : setEID(@spr_db_h0          ,sms_death);
        EID_db_h1         : setEID(@spr_db_h1          ,sms_death);
        EID_db_u0         : setEID(@spr_db_u0          ,sms_death);
        EID_db_u1         : setEID(@spr_db_u1          ,sms_death);
        UID_UGTurret      : setEID(@spr_UTurret        ,sms_build);
        UID_UATurret      : setEID(@spr_URTurret       ,sms_build);
      end;
   end;
end;

procedure ui_click_eff(cx,cy,ca:integer;cc:TMWColor);
begin
   ui_mc_x:=cx;
   ui_mc_y:=cy;
   ui_mc_a:=ca;
   ui_mc_c:=cc;
end;

procedure effect_add(ex,ey,ed:integer;ee:byte;skipVisionCheck:boolean=false);
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
         then sc := sm^.sm_spritesNum
         else
           if(ei<sm^.sm_spritesNum)
           then sc := sm^.sm_spritesNum-ei
           else sc := sm^.sm_spritesNum;

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
   if(MainMenu)
   or(g_status<>gs_running)
   or(not vid_draw)
   or(ee=0)
   or(g_eids[ee].smodel=nil)then exit;

   if(not skipVisionCheck)then
     if(not ui_CheckMapPointFogVision(ex,ey,true))then exit;

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
MID_SChaingun,
MID_Chaingun      : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_BFG           : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Flyer         : setEff(6 ,0 ,-1 ,-1       ,false,0 );

MID_Imp           : setEff(6 ,0 ,-1 ,-1       ,false,0 );
MID_Cacodemon     : setEff(6 ,0 ,-1 ,-1       ,false,0 );

MID_Baron,
MID_URocketS,
MID_URocket,
MID_Revenant      : setEff(7 ,0 , 8 ,-1       ,false,0 );
MID_YPlasma       : setEff(6 ,0 ,-1 ,-1       ,false,0 );

EID_BFG           : setEff(6 ,0 ,-1 ,-1       ,true ,0 );

MID_CyberRocket,
MID_Granade,
MID_Tank,
MID_Mancubus,
EID_Exp3,
EID_Exp1          : setEff(7 ,0 ,-1 ,-1       ,true ,0 );
EID_Exp2          : setEff(7 ,0 ,-1 ,-1       ,true ,0 );

EID_Blood         : setEff(6 ,0 ,-1 ,-1       ,true ,15);

MID_ArchFire,
EID_ArchFire      : setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HLevelUp,
EID_ULevelUp,
EID_HVision,
EID_UnitCaptured,
EID_PowerUp,
EID_Teleport      : setEff(10,0 ,-1 ,-1       ,true ,0 );
EID_InfantryGibs  : setEff(7 ,0 ,-1 ,dead_time,true ,0 );

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
EID_db_u1         : setEff(0 ,0 ,0  ,dead_time ,false,0 );
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

procedure missile_explode_effect(m:integer);
var i,o,r:byte;
begin
   with g_missiles[m] do
   with g_mids[m_mid] do
     if(ui_CheckMapPointFogVision(m_x,m_y,true))then
     begin
        o:=mid_eid_DeathN[m_eid_DeathType];
        r:=mid_eid_DeathR[m_eid_DeathType];
        if(r<2)or(o<2)then
        begin
           r:=0;
           o:=1;
        end;
        for i:=1 to o do effect_add(m_x-random(r)+random(r),
                                    m_y-random(r)+random(r),draw_DefaultSpriteDepth(m_y,m_mfs)+100,mid_eid_death[m_eid_DeathType]);

        if(m_mfe=uf_ground)and(mid_eid_Decal>0)then effect_add(m_x,m_y,sd_liquidFront+m_y,mid_eid_Decal);

        if(mid_snd_DeathSkip[m_eid_DeathType]>0)then
          if(random(mid_snd_DeathSkip[m_eid_DeathType])>0)then exit;

        snd_SoundPlayUnit(mid_snd_death[m_eid_DeathType],nil,nil);
     end;
end;

procedure missiles_AddSprites;
var  m:integer;
   spr:PTMWTexture;
begin
   for m:=0 to MaxMissiles do
     with g_missiles[m] do
       if(m_mid=MID_Blizzard)
       or(ui_CheckMapPointFogVision(m_x,m_y,true))then
         with g_mids[m_mid] do
           if(m_vstep>0)then
           begin
              if(m_mid=MID_Blizzard)then
                if(UACStrike_t0<=m_vstep)and(m_vstep<=UACStrike_t1)then continue;

              spr:=SpriteModel2Sprite(mid_SpriteModel,sms_stand,m_dir,byte(m_mid=MID_Blizzard)*byte(m_vstep<=UACStrike_t1),nil);
              SpriteList_AddEffect(m_x,m_y,draw_DefaultSpriteDepth(m_y,m_mfs)+100,0,spr,255);

              if(mid_eid_FlyStep>0)and(mid_eid_FlyTrace>0)then
                if((m_vstep mod mid_eid_FlyStep)=0)then
                  effect_add(m_x,m_y,draw_DefaultSpriteDepth(m_y,m_mfs),mid_eid_FlyTrace);
           end;
end;


procedure effect_teleport(sx,sy,tx,ty:integer;ukfly:boolean;seid,eeid:byte;snd:PTSoundSet;pUIVisS,pUIVisT:pboolean);
type ppboolean = ^pboolean;
function CheckPVis(ppvis:ppboolean):boolean;
begin
   CheckPVis:=false;
   if(ppvis^<>nil)then
     CheckPVis:=ppvis^^;
end;
begin
   if (0<sx)and(sx<map_Size1)
   and(0<sy)and(sy<map_Size1)then
     if(CheckPVis(@pUIVisS))then
       effect_add(sx,sy,draw_DefaultSpriteDepth(sy+1,ukfly),seid,true);

   if (0<tx)and(tx<map_Size1)
   and(0<ty)and(ty<map_Size1)then
     if(CheckPVis(@pUIVisT))then
       effect_add(tx,ty,draw_DefaultSpriteDepth(ty+1,ukfly),eeid,true);

   if(CheckPVis(@pUIVisS))
   or(CheckPVis(@pUIVisT))
   then snd_SoundPlayUnit(snd,nil,nil);

   {if(pUnitVis<>nil)then
     if(not ui_CheckUnitUIPlayerVision(pUnitVis,false))then exit;

   if(PointInCam(sx,sy))
   or(PointInCam(tx,ty))
   then snd_SoundPlayUnit(snd,nil,nil);

   if (0<sx)and(sx<map_Size1)
   and(0<sy)and(sy<map_Size1)then effect_add(sx,sy,draw_DefaultSpriteDepth(sy+1,ukfly),seid,true);
   if (0<tx)and(tx<map_Size1)
   and(0<ty)and(ty<map_Size1)then effect_add(tx,ty,draw_DefaultSpriteDepth(ty+1,ukfly),eeid  ,true);  }
end;

procedure effects_AddSprites(noanim:boolean);
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
         else alpha:=min2i(255,anim_last_i_t);
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

        if(anim_step>0)
        then spr:=SpriteModel2Sprite(smodel,anim_smstate,270,anim_i div anim_step,@anim_stat)
        else spr:=SpriteModel2Sprite(smodel,anim_smstate,270,anim_i              ,@anim_stat);

        if(RectInCam(x,y,spr^.hw,spr^.hh,0))then SpriteList_AddEffect(x,y,d,smask,spr,alpha);
     end;
end;

