
//procedure _d1  (d:pinteger);begin d^:=0             end;
procedure _d25 (d:pinteger);begin d^:=d^ div 4;     end;
procedure _d50 (d:pinteger);begin d^:=d^ div 2;     end;
procedure _d75 (d:pinteger);begin d^:=d^-(d^ div 4);end;
procedure _d125(d:pinteger);begin d^:=d^+(d^ div 4);end;
procedure _d150(d:pinteger);begin d^:=d^+(d^ div 2);end;
procedure _d200(d:pinteger);begin d^:=d^*2;         end;
procedure _d300(d:pinteger);begin d^:=d^*3;         end;
procedure _d400(d:pinteger);begin d^:=d^*4;         end;
procedure _dbfg(r:integer;d:pinteger);
var i:integer;
begin
   i:=mm3(-4,trunc((r-15)/1.5),4);
   if(i<>0)then d^:=d^+(d^ div 4)*i;
end;

function _unit_melee_damage(pu,tu:PTUnit;damage:integer):integer;
begin
   with _players[pu^.player] do
    if(upgr[upgr_melee]>0)then
     case race of
       r_hell : damage+=upgr[upgr_melee]*5;
       r_uac  : damage+=upgr[upgr_melee]*2;
     end;

   case pu^.uid of
   UID_LostSoul: begin
                    if(tu^.mech               )then _d25 (@damage) else
                    if(tu^.uf=uf_ground       )then _d50 (@damage);
                 end;
   end;

   _unit_melee_damage:=damage;
end;

procedure _miss_add(mx,my,mvx,mvy,mtar:integer;msid,mpl,mft:byte;instant:boolean);
var m:integer;
    tu:PTUnit;
begin
   for m:=1 to MaxUnits do
    with _missiles[m] do
     if(vst=0)then
     begin
        x      := mx;
        y      := my;
        vx     := mvx;
        vy     := mvy;
        tar    := mtar;
        mid    := msid;
        player := mpl;
        mf     := mft;
        mtars  := 0;
        ntars  := 0;

        sr:=dist2(x,y,vx,vy);

        if(mid<>MID_Blizzard)then
         if(sr>missile_mr)then exit;

        case mid of
MID_Imp        : begin dam:=7  ; vst:=sr div 8 ; sr :=0  ;       end;
MID_Cacodemon  : begin dam:=20 ; vst:=sr div 8 ; sr :=0  ;       end;
MID_Baron      : begin dam:=30 ; vst:=sr div 8 ; sr :=0  ;       end;
MID_RevenantS,
MID_Revenant   : begin dam:=7  ; vst:=sr div 12; sr :=0  ;       dir:=((p_dir(vx,vy,x,y)+23) mod 360) div 45;end;
MID_Mancubus   : begin dam:=20 ; vst:=sr div 8 ; sr :=0  ;       dir:=((p_dir(vx,vy,x,y)+23) mod 360) div 45;end;
MID_ArchFire   : begin dam:=100; vst:=1;         sr :=12 ;       end;
MID_MineShock  : begin dam:=0  ; vst:=1;         sr :=100;       end;
MID_MBullet,
MID_TBullet,
MID_Bullet     : begin dam:=4  ; vst:=1;         sr :=0  ;       end;
MID_Bulletx2   : begin dam:=7  ; vst:=1;         sr :=0  ;       end;
MID_YPlasma    : begin dam:=7  ; vst:=sr div 18; sr :=0  ;       end;
MID_BPlasma    : begin dam:=7  ; vst:=sr div 15; sr :=0  ;       end;
MID_BFG        : begin dam:=125; vst:=sr div 8 ; sr :=125;       end;
MID_Flyer      : begin dam:=7  ; vst:=sr div 60; sr :=0  ;       end;
MID_HRocket    : begin dam:=50 ; vst:=sr div 15; sr :=rocket_sr; dir:=((p_dir(vx,vy,x,y)+23) mod 360) div 45;end;
MID_Granade    : begin dam:=20 ; vst:=sr div 10; sr :=rocket_sr; end;
MID_Tank       : begin dam:=30 ; vst:=1;         sr :=rocket_sr; end;
MID_Mine       : begin dam:=175; vst:=1;         sr :=100;       end;
MID_Blizzard   : begin dam:=300; vst:=vid_fps;   sr :=blizz_r;   dir:=((p_dir(vx,vy,x,y)+23) mod 360) div 45;end;
MID_SShot      : begin dam:=8 ;  vst:=1;         sr :=0;         end;
MID_SSShot     : begin dam:=16;  vst:=1;         sr :=0;         end;
        else
          vst:=0;
          exit;
        end;

        if(vst<=0)or(instant)then vst:=1;

        if(mtars=0)then
         if(tar=0)or(sr>0)
         then mtars:=MaxUnits
         else mtars:=1;

        if(tar>0)and(mid<>MID_RevenantS)then
        begin
           tu:=@_units[tar];
           mx:=tu^.r shr 1;
           x+=_randomr(mx);
           y+=_randomr(mx);
        end;

        with _players[player] do
        begin
           if(upgr[upgr_attack]>0)then
            case mid of
MID_Revenant,
MID_RevenantS,
MID_Imp,
MID_YPlasma,
MID_BPlasma    : dam+=upgr[upgr_attack]*2;
MID_SShot,
MID_SSShot,
MID_Granade,
MID_Cacodemon  : dam+=upgr[upgr_attack]*3;
MID_HRocket,
MID_Tank,
MID_Baron,
MID_Mancubus   : dam+=upgr[upgr_attack]*4;
MID_Mine,
MID_BFG,
MID_ArchFire   : dam+=upgr[upgr_attack]*5;
MID_Blizzard   : ;
            else dam+=upgr[upgr_attack];
            end;

           if(race=r_hell)then
           if(upgr[upgr_misfst]>0)then
            case mid of
MID_Imp,
MID_Cacodemon,
MID_Baron      : vst:=vst-(vst div 2);
            end;
        end;

        break;
     end;
end;

function _miduid(mid,uid:byte):boolean;
begin
   _miduid:=false;

   case mid of
MID_Imp      : if(uid=UID_Imp        )then exit;
MID_Cacodemon: if(uid=UID_Cacodemon  )then exit;
MID_Baron    : if(uid=UID_Baron      )then exit;
MID_Mancubus : if(uid=UID_Mancubus   )then exit;
MID_YPlasma  : if(uid=UID_Arachnotron)then exit;
MID_Revenant,
MID_RevenantS: if(uid=UID_Revenant   )then exit;
   end;

   _miduid:=true;
end;


procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
d,damd: integer;
     p: byte;
begin
   p:=0;
   with _missiles[m] do
   begin
      tu:=@_units[tar];

      if(tu^.hits>0)and(_miduid(mid,tu^.uid))and(tu^.inapc=0)then
        if(abs(mf-tu^.uf)<2)then
        begin
           teams:=_players[player].team=_players[tu^.player].team;
           damd :=dam;

           if(teams)then
            case mid of
            MID_ArchFire: if(tu^.uid in [UID_Archvile,UID_HTotem])then exit;
            end;

           d:=dist2(vx,vy,tu^.x,tu^.y)-tu^.r;
           if(sr=0)then d-=15;
           if(d<0)then d:=0;

           if(OnlySVCode)then
           begin
              if(teams)then
               if(tu^.isbuild)
               then damd:=damd div 4
               else damd:=damd div 2;
              p:=1;

              if(tu^.uid in armor_lite)then  // bio: light
                  case mid of
                  MID_MBullet,
                  MID_TBullet,
                  MID_Bullet      : _d300(@damd);
                  MID_Bulletx2,
                  MID_Cacodemon   : _d200(@damd);
                  MID_Baron,
//                  MID_SShot,
                  MID_SSShot,
                  MID_BFG,
                  MID_Tank,
                  MID_Granade,
                  MID_Mancubus    : _d50 (@damd);
                  //MID_HRocket
                  end
              else
              if(tu^.mech=false)then          // bio: not light
                  case mid of
                  MID_SShot,
                  MID_SSShot,
                  MID_Imp         : _d300(@damd);
                  end
              else
                  case mid of                 // mech
                  MID_SShot,
                  MID_SSShot,
                  MID_MBullet,
                  MID_TBullet,
                  MID_Bullet,
                  MID_Bulletx2    : _d25 (@damd);
                  else
                  if(tu^.isbuild=false)then   // mech
                  case mid of
                  MID_BPlasma,
                  MID_YPlasma     : _d300(@damd);
                  end
                  else                        // building
                  case mid of
                  MID_Tank,
                  MID_Granade,
                  MID_Mancubus    : _d300(@damd);
                  MID_HRocket     : _d200(@damd);
                  end;
                  end;


              if(tu^.uf>uf_ground)then
                  case mid of
                  MID_Baron,
                  MID_Cacodemon   : _d50 (@damd);
                  MID_Revenant,
                  MID_Revenants,
                  MID_Flyer       : _d300(@damd);
                  else
                  if(tu^.uf>uf_soaring)then
                  case mid of
                      MID_Imp     : _d50 (@damd);
                  end;
                  end;


             { /////////////////////////////////
              if(tu^.uid in armor_lite)then  // bio: light
                 case mid of
                 MID_Granade,
                 MID_Tank,
                 MID_Baron,
                 MID_Mancubus    : _d25 (@damd);
                 MID_HRocket,
                 MID_Blizzard,
                 MID_BPlasma,
                 MID_SShot,
                 MID_SSShot      : _d50 (@damd);
                 MID_Cacodemon,
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet,
                 MID_Bulletx2    : _d150(@damd);
                 end
             else
             if(tu^.mech=false)then          // bio: not light
                 case mid of
                 MID_Imp         : _d150(@damd);
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet      : _d50 (@damd);
                 end
             else
                 case mid of                 // mech
                 MID_SShot,
                 MID_SSShot,
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet      : _d25 (@damd);
                 MID_Cacodemon,
                 MID_Imp         : _d50 (@damd);
                 MID_Baron       : _d75 (@damd);
                 else
                   // mechs
                   if(tu^.isbuild=false)then
                   case mid of
                   MID_YPlasma     : _d400(@damd);
                   MID_BPlasma     : _d200(@damd);
                   MID_Tank,
                   MID_Bulletx2,
                   MID_HRocket,
                   MID_Granade     : _d50 (@damd);
                   MID_Mancubus    : _d75 (@damd);
                   end
                   else
                   // buildings
                   case mid of
                   MID_Archfire    : _d50 (@damd);
                   MID_Bulletx2    : _d25 (@damd);
                   MID_Blizzard    : _d200(@damd);
                   MID_HRocket,
                   MID_Mancubus,
                   MID_Granade,
                   MID_Tank        : _d200(@damd);
                   MID_BPlasma     : _d50 (@damd);
                   end;
                 end;

              if(tu^.uf>uf_ground)then
              begin
                 if(tu^.isbuild=false)then
                 begin
                    case mid of
                 MID_Imp,
                 MID_Mancubus,
                 MID_Baron       : _d75 (@damd);
                    end;

                    if(tu^.uf=uf_soaring)then
                    case mid of
                 MID_Cacodemon   : _d50 (@damd);
                    end;
                    if(tu^.uf>uf_soaring)then
                    case mid of
                 MID_Blizzard    : if(tu^.isbuild=false)then _d75 (@damd);
                 MID_SShot,
                 MID_SSShot      : _d75 (@damd);
                    end;
                 end;

                 case mid of
                 MID_Flyer       : _d400(@damd);
                 MID_Revenant,
                 MID_RevenantS   : _d300(@damd);
                 end;
                 case mid of
                 MID_BPlasma     : if(mf=tu^.uf)
                                   then _d75 (@damd)
                                   else _d50 (@damd);
                 end;
              end;}

              case mid of
              MID_BPlasma     : if(sign(mf)<>sign(tu^.uf))then _d50 (@damd);
              MID_SShot       : p:=4;
              MID_SSShot      : p:=8;
              MID_BFG         : begin
                                   _dbfg(tu^.r,@damd);
                                   if(tu^.isbuild)then _d25 (@damd);
                                end;
              end;
           end;

           if(d<=0)and(ntars=0)then // direct
           begin
              if(onlySVCode)then
               if(tu^.buff[ub_invuln]=0)then
               begin
                  if(mid=MID_TBullet)and(tu^.mech=false)then
                  begin
                     if(tu^.buff[ub_toxin]>=0)then
                      if(tu^.uid in marines)
                      then begin tu^.buff[ub_toxin]:=vid_hfps; tu^.buff[ub_pain ]:=vid_hfps;end
                      else begin tu^.buff[ub_toxin]:=vid_fps;  tu^.buff[ub_pain ]:=vid_fps; end;
                  end;
                  if(mid=MID_MBullet)and(tu^.mech)and(tu^.isbuild=false)then
                  begin
                     tu^.buff[ub_toxin]:=vid_fps;
                     tu^.buff[ub_pain ]:=vid_fps;
                  end;
               end;
              if(mid=MID_MineShock)then
              begin
                 if(tu^.isbuild=false)and(teams=false)then
                 begin
                    if(onlySVCode)then
                    begin
                       tu^.buff[ub_toxin]:=vid_3hfps;
                       tu^.buff[ub_pain ]:=vid_3hfps;
                    end;
                    {$IFDEF _FULLGAME}
                    _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,MID_BPlasma);
                    {$ENDIF}
                 end
                 else exit;
              end;

              {$IFDEF _FULLGAME}
              if(mid in [MID_SShot,MID_SSShot,MID_Bullet,MID_Bulletx2,MID_TBullet,MID_MBullet])then
              begin
                 if(tu^.mech)
                 then _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,MID_Bullet)
                 else _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,EID_Blood );
              end;
              {$ENDIF}

              mtars-=1;
              ntars+=1;

              if(onlySVCode)then _unit_damage(tar,damd,p,player);
           end
           else
             if(sr>0)and(d<sr)then
             begin
                if(mid in [MID_SShot,MID_SSShot])then
                begin
                   {$IFDEF _FULLGAME}
                   if(tu^.mech)
                   then _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,MID_Bullet)
                   else _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,EID_Blood );
                   {$ENDIF}
                   mtars-=1;
                   _unit_damage(tar,damd,p,player);
                   exit;
                end;
                if(mid=MID_MineShock)then
                begin
                   if(tu^.isbuild=false)and(teams=false)then
                   begin
                      if(onlySVCode)then
                      begin
                         tu^.buff[ub_toxin]:=vid_3hfps;
                         tu^.buff[ub_pain ]:=vid_3hfps;
                      end;
                      {$IFDEF _FULLGAME}
                      _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,MID_BPlasma);
                      {$ENDIF}
                   end
                   else exit;
                end;

                if(mid in [MID_HRocket,MID_Tank,MID_Granade,UID_Archvile])then
                begin
                   if(tu^.uid in [UID_Cyberdemon,UID_Mastermind,UID_Tank])then exit;
                   if(tu^.uid in armor_lite)then damd:=damd div 2;
                end;

                {$IFDEF _FULLGAME}
                if(mid in [MID_Bullet,MID_Bulletx2,MID_TBullet,MID_MBullet])then
                begin
                   if(tu^.mech)
                   then _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,MID_Bullet)
                   else _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,EID_Blood);
                end;
                {$ENDIF}

                if(mid=MID_BFG)then
                begin
                   if(teams)then exit;
                   {$IFDEF _FULLGAME}
                   _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,EID_BFG);
                   {$ENDIF}
                end;

                mtars-=1;
                ntars+=1;

                if(onlySVCode)then
                begin
                   damd:=trunc(damd*(1-(d/sr)) );
                   _unit_damage(tar,damd,p,player);
                end;
             end;
        end;
   end;
end;

procedure _missileCycle(onlyspr:boolean);
const  mb_s0 = vid_fps div 6;
       mb_s1 = vid_fps-mb_s0;
var m,u:integer;
    {$IFDEF _FULLGAME}
    d  :integer;
    spr:PTUSprite;
    {$ENDIF}
begin
   for m:=1 to MaxUnits do
    with _missiles[m] do
     if(vst>0)then
     begin
        if(onlyspr=false)then
        begin
           if(mid=MID_RevenantS)then
            if(tar>0)then
            begin
               x  :=_units[tar].x;
               y  :=_units[tar].y;
               mf :=_units[tar].uf;
            end;

           if(mid=MID_Blizzard)then
           begin
              if(vst>mb_s1)
              then vy-=vid_fps
              else
               if(vst=mb_s1)then
               begin
                  vx:=x;
                  vy:=y-(vid_fps*mb_s0);
               end
               else
                 if(vst<=mb_s0)then vy+=vid_fps;
           end
           else
           begin
              vx+=(x-vx) div vst;
              vy+=(y-vy) div vst;
           end;
           vst-=1;

           case mid of
           MID_Granade  : vy-=vst div 3;
           end;

           if(dam>0)and(vst=0)then
            if(tar>0)and(mtars=1)
            then _missle_damage(m)
            else
              for u:=1 to MaxUnits do
              begin
                 tar:=u;
                 _missle_damage(m);
                 if(mtars<=0)then break;
              end;
         end;

        {$IFDEF _FULLGAME}

        if(mid=MID_Blizzard)then
        begin
           if(vst=0)then
           begin
              _effect_add(vx,vy+10,-10,eid_db_h0);
              _effect_add(vx,vy,map_flydpth[mf]+vy+5,EID_BBExp);
              PlaySND(snd_exp,0);
              continue;
           end;
           if(mb_s0<vst)and(vst<mb_s1)then continue;
        end;

        case mid of
        MID_Flyer    : spr:=@spr_u_p3[0  ];
        MID_Imp      : spr:=@spr_h_p0[0  ];
        MID_Cacodemon: spr:=@spr_h_p1[0  ];
        MID_Baron    : spr:=@spr_h_p2[0  ];
        MID_Blizzard,
        MID_HRocket  : spr:=@spr_h_p3[dir];
        MID_Tank,
        MID_Granade  : spr:=@spr_h_p3[2  ];
        MID_RevenantS,
        MID_Revenant : spr:=@spr_h_p4[dir];
        MID_Mancubus : spr:=@spr_h_p5[dir];
        MID_YPlasma  : spr:=@spr_h_p7[0  ];
        MID_BPlasma  : spr:=@spr_u_p0[0  ];
        MID_BFG      : spr:=@spr_u_p2[0  ];
        else spr:=@spr_dummy;
        end;

        if(_nhp3(vx,vy,player))then
        begin
           d:=map_flydpth[mf]+vy;
           if(vst>0)then
           begin
              case mid of
                MID_RevenantS,
                MID_HRocket,
                MID_Granade  : if((vst mod 4)=0)then _effect_add(vx,vy,d-1,MID_Bullet);
                MID_Blizzard : if((vst mod 3)=0)then _effect_add(vx,vy,d-1,EID_Exp);
                MID_Flyer    : _effect_add(vx,vy,d-1,MID_Flyer);
              end;

              _sl_add(vx-spr^.hw, vy-spr^.hh,d,0,0,0,false,spr^.surf,255,0,0,0,0,'',0);
           end
           else
           begin
              case mid of
                 MID_Flyer   : PlaySND(snd_fly_a1,0);
                 MID_ArchFire: begin PlaySND(snd_exp,0); exit; end;
                 MID_Imp,
                 MID_Cacodemon,
                 MID_Baron,
                 MID_Mancubus,
                 MID_BPlasma,
                 MID_YPlasma : PlaySND(snd_pexp,0);
                 MID_BFG     : PlaySND(snd_bfgepx,0);
                 MID_Revenant,
                 MID_Granade,
                 MID_Tank,
                 MID_HRocket : PlaySND(snd_exp,0);
                 MID_Blizzard: PlaySND(snd_exp2,0);
                 MID_SShot,
                 MID_SSShot,
                 MID_MBullet,
                 MID_Bullet,
                 MID_Bulletx2,
                 MID_TBullet : if(random(4)=0)then PlaySND(snd_rico,0);
              end;

              if(mid in [MID_SShot,MID_SSShot,MID_Bullet,MID_Bulletx2,MID_TBullet,MID_MBullet])then
              begin
                 //if(mf=uf_ground)then
                 // if(mid in [MID_SShot,MID_SSShot])then
                //   for u:=1 to mtars do _effect_add(vx-sr+random(sr shl 1),vy-sr+random(sr shl 1),d+40,mid_Bullet);
                 continue;
              end;

              _effect_add(vx,vy,d+50,mid);
           end;
        end;
        {$ENDIF}
     end;
end;





