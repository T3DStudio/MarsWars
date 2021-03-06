
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

        MID_Imp           : _setEID(@spr_h_p0          ,sms_death);
        MID_Cacodemon     : _setEID(@spr_h_p1          ,sms_death);
        MID_Baron         : _setEID(@spr_h_p2          ,sms_death);
        MID_Revenant,
        MID_RevenantS     : _setEID(@spr_h_p4          ,sms_death);
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
        EID_BExp          : _setEID(@spr_eff_eb        ,sms_death);
        MID_Blizzard,
        EID_BBExp         : _setEID(@spr_eff_ebb       ,sms_death);
        EID_HKT_h,
        EID_HKT_s         : _setEID(@spr_HKeep         ,sms_walk );
        EID_HMU           : _setEID(@spr_UCommandCenter,sms_walk );
        EID_HCC           : _setEID(@spr_UMilitaryUnit ,sms_walk );
        EID_HAMU          : _setEID(@spr_UAMilitaryUnit,sms_walk );
        EID_db_h0         : _setEID(@spr_db_h0         ,sms_death);
        EID_db_h1         : _setEID(@spr_db_h1         ,sms_death);
        EID_db_u0         : _setEID(@spr_db_u0         ,sms_death);
        EID_db_u1         : _setEID(@spr_db_u1         ,sms_death);
        UID_UCTurret      : _setEID(@spr_UTurret       ,sms_build);
        UID_UPTurret      : _setEID(@spr_UPTurret      ,sms_build);
        UID_URTurret      : _setEID(@spr_URTurret      ,sms_build);
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
   if(_menu)or(g_paused>0)or(_draw=false)or(ee=0)or(_eids[ee].smodel=nil)then exit;

   for e:=1 to vid_mvs do
   with _effects[e] do
   if(anim_last_i_t=0)then
   begin
      case ee of
UID_Pain          : _setEff(9 ,0 ,32 ,-1       ,false,0 );
UID_LostSoul      : _setEff(7 ,0 ,23 ,-1       ,false,0 );
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
MID_Revenant,
MID_RevenantS     : _setEff(7 ,0 , 8 ,-1       ,false,0 );
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

EID_BExp          : _setEff(5 ,0 ,-1 ,-1       ,true ,0 );
MID_Blizzard,
EID_BBExp         : _setEff(6 ,0 ,-1 ,-1       ,true ,0 );

EID_HKT_h,
EID_HKT_s,
EID_HMU,
EID_HCC,
EID_HAMU          : _setEff(0 ,3 ,3  ,fr_fps   ,false,0 );

UID_UCTurret,
UID_UPTurret,
UID_URTurret,
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

procedure _unit_bullet_puff(tu:PTUnit);
begin
   with tu^ do
    with uid^ do
     if(_ismech)
     then _effect_add(x-_randomr(_missile_r),y-_randomr(_missile_r),_depth(vy+1,uf),MID_Bullet)
     else _effect_add(x-_randomr(_missile_r),y-_randomr(_missile_r),_depth(vy+1,uf),EID_Blood );
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
begin
   with _missiles[m] do
   with _mids[mid] do
   begin
      if(_nhp3(vx,vy,@_players[player]))then
      begin
         if(ms_alt_death=false)
         then _effect_add(vx,vy,_depth(vy,mfs),mid)
         else
         begin
            sr:=trunc(sr*0.75);
            while(mtars>0)do
            begin
               _effect_add(vx-_randomr(sr),vy-_randomr(sr),_depth(vy,mfs),mid);
               dec(mtars,1);
            end;
         end;


         //if(ms_eid_death>0)then _effect_add(vx,vy,vy+map_flydpth[mf],ms_eid_death);
         if(ms_eid_decal>0)then _effect_add(vx,vy,-6                ,ms_eid_decal);

         if(ms_snd_death_ch>0)then
          if(random(ms_snd_death_ch)>0)then exit;

         PlaySND(ms_snd_death,nil,nil);
      end;
   end;
end;

procedure missiles_sprites(noanim,draw:boolean);
var  m:integer;
   spr:PTMWTexture;
begin
   for m:=1 to MaxMissiles do
   with _missiles[m] do
   with _mids[mid] do
   if(vst>0)then
   begin
      spr:=@spr_dummy;

      spr:=_sm2s(ms_smodel,sms_stand,dir,0,nil);

      if(draw)then
       if(_rectvis(vx,vy,spr^.hw,spr^.hh,0))then _sl_add_eff(vx,vy,_depth(vy,mfs),0,spr,255);
   end;
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

        if(anim_step>0)
        then spr:=_sm2s(smodel,anim_smstate,270,anim_i div anim_step,@anim_stat)
        else spr:=_sm2s(smodel,anim_smstate,270,anim_i              ,@anim_stat);

        if(draw)then
         if(_rectvis(x,y,spr^.hw,spr^.hh,0))then _sl_add_eff(x,y,d,smask,spr,alpha);
     end;
end;

