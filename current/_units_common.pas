{$IFDEF _FULLGAME}
procedure unit_MiniMapXY(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mmcx);
      mmy:=trunc(y*map_mmcx);
      //mmsx:=(mmx shr 2)shl 2;
      //mmsy:=(mmy shr 2)shl 2;
   end;
end;

procedure effect_LevelUp(pu:PTUnit;etype:byte;vischeck:pboolean);
begin
   with pu^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(not CheckUnitUIVisionScreen(pu))then exit;

      case etype of
EID_HVision : begin
              SoundPlayUnit(snd_hell_eye,pu,nil);
              effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_HVision);
              end;
EID_Invuln  : begin
              SoundPlayUnit(snd_hell_invuln,pu,nil);
              effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_Invuln);
              end;
      else
         case uid^._urace of
r_hell : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_HLevelUp);
         end;
r_uac  : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_ULevelUp);
         end;
         end;
      end;
   end;
end;

procedure effect_UACStrikeShot(pu:PTUnit);
begin
   with pu^ do
   begin
      effect_add(vx,vy-15,SpriteDepth(vy+10,ukfly),EID_Exp2);
      SoundPlayUnit(snd_bomblaunch,nil,nil)
   end;
end;

procedure effect_CPExplode(vx,vy:integer);
begin
   effect_add(vx,vy,sd_liquid+vy,EID_db_u0);
   if(MapPointInScreenP(vx,vy))then
   begin
      effect_add(vx,vy,SpriteDepth(vy+1,false),EID_BBExp);
      SoundPlayUnit(snd_exp,nil,nil);
   end;
end;

procedure effect_UnitSummon(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   if(hits>0)and(iscomplete)then
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
         if(not CheckUnitUIVisionScreen(pu))then exit;

      SoundPlayUnit(un_eid_snd_summon,nil,nil);
      effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_summon[level]);

      if(playeri=UIPlayer)then SoundPlayUnit(un_snd_ready,nil,nil);
   end;
end;

procedure effect_UnitDeath(pu:PTUnit;fastdeath:boolean;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(not ukfly)then
      effect_add(vx,vy+un_eid_bcrater_y,sd_liquid+vy,un_eid_bcrater);

      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(not CheckUnitUIVisionScreen(pu))then exit;

      if(fastdeath)then
      begin
         effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_fdeath[level]);
         SoundPlayUnit(un_eid_snd_fdeath,nil,nil);
      end
      else
      begin
         effect_add(vx,vy,vy+1,un_eid_death[level]);
         SoundPlayUnit(un_eid_snd_death,nil,nil);
      end;
   end;
end;

procedure effect_UnitPain(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(not CheckUnitUIVisionScreen(pu))then exit;

      effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_pain[level]);
      SoundPlayUnit(un_eid_snd_pain,nil,nil);
   end;
end;

procedure effect_InPoint(tx,ty,dy:integer;vischeck:pboolean;effect:byte;sound:PTSoundSet);
begin
   if(vischeck<>nil)then
   begin
      if(vischeck^=false)then exit
   end
   else
     if(MapPointInScreenP(tx,ty)=false)then exit;

   effect_add(tx,ty,dy,effect);
   SoundPlayUnit(sound,nil,nil);
end;

procedure effect_UnitAttack(pu:PTUnit;start:boolean;vischeck:pboolean);
begin
   with pu^  do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if(vischeck<>nil)then
      begin
         if(vischeck^=false)then exit
      end
      else
        if(not CheckUnitUIVisionScreen(pu))then exit;

      if(start)then
      begin
         effect_add(vx,vy,SpriteDepth(vy+1,ukfly),aw_eid_start);
         SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         effect_add(vx+aw_x,vy+aw_y,SpriteDepth(vy+1,ukfly),aw_eid_shot );
         SoundPlayUnit(aw_snd_shot,nil,nil);
      end;
   end;
end;

{$ENDIF}

procedure unit_SetOrder(pu:PTUnit;otarget,ox,oy,obx,oby:integer;oid:byte);
begin
   with pu^ do
   begin
      ua_bx :=obx;
      ua_by :=oby;
      ua_x  :=ox;
      ua_y  :=oy;
      ua_tar:=otarget;
      ua_id :=oid;
   end;
end;

function unit_UA2UO(pu:PTUnit):byte;
begin
   with pu^ do
     if(ua_bx>=0)then
     begin
        if(ua_id=ua_attack)
        then unit_UA2UO:=uo_apatrol
        else unit_UA2UO:=uo_patrol;
     end
     else
       case ua_id of
       ua_move     : if(ua_x=x)and(ua_y=y)
                     then unit_UA2UO:=uo_stay
                     else unit_UA2UO:=uo_move;
       ua_hold     : unit_UA2UO:=uo_hold;
       ua_unload   : unit_UA2UO:=uo_unload;
       ua_psability: unit_UA2UO:=uo_psability;
       else
           if(ua_x=x)and(ua_y=y)
           then unit_UA2UO:=uo_stay
           else unit_UA2UO:=uo_attack;
       end;
end;
procedure unit_ClientUO2UA(pu:PTUnit;uo_order:byte);
begin
   with pu^ do
     case uo_order of
     uo_move     : unit_SetOrder(pu,0,x,y,-1,-1,ua_move     );
     uo_stay,
     uo_attack   : unit_SetOrder(pu,0,x,y,-1,-1,ua_attack   );
     uo_hold     : unit_SetOrder(pu,0,x,y,-1,-1,ua_hold     );
     uo_psability: unit_SetOrder(pu,0,x,y,-1,-1,ua_psability);
     uo_unload   : unit_SetOrder(pu,0,x,y,-1,-1,ua_unload   );
     uo_patrol   : unit_SetOrder(pu,0,x,y, x, y,ua_move     );
     uo_apatrol  : unit_SetOrder(pu,0,x,y, x, y,ua_attack   );
     else          unit_SetOrder(pu,0,x,y,-1,-1,ua_attack   );
     end;
end;

function unit_canMove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
    if(ServerSide=false)and(speed>0)
    then unit_canMove:=(x<>mv_x)or(y<>mv_y)
    else
    begin
       unit_canMove:=false;

       if(speed<=0)
       or(hits<=0)
       or(not iscomplete)
       or(StayWaitForNextTarget>0)then exit;

       if(a_reload>0)then
        if(a_weap_cl>MaxUnitWeapons)
        then exit
        else
         with _a_weap[a_weap_cl] do
          if((aw_reqf and wpr_move)=0)then exit;

       if(not _ukbuilding)then
         if(buff[ub_Pain]>0)
         or(buff[ub_Cast]>0)then exit;

       unit_canMove:=true;
    end;
end;

function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean;
var tu:PTUnit;
begin
   unit_canAttack:=false;
   with pu^  do
   with uid^ do
   begin
      if(not iscomplete)
      or(hits<=0)
      or(_attack=atm_none)then exit;

      if(check_buffs)then
      begin
         if(not _ukbuilding)then
           if(buff[ub_Pain]>0)
           or(buff[ub_Cast]>0)then exit;
      end;

      case _attack of
   atm_bunker,
   atm_always  : if(IsUnitRange(transport,@tu))then
                 begin
                    if(IsUnitRange(tu^.transport,nil))then exit;
                    case tu^.uid^._attack of
                    atm_always,
                    atm_none,
                    atm_sturret: exit;
                    end;
                 end;
   atm_sturret : if(transportC<=0)then exit;
   atm_inapc   : if(transport <=0)then exit;
      else exit;
      end;
   end;
   unit_canAttack:=true;
end;

procedure unit_UpdateXY(pu:PTUnit);
var newzone:word;
begin
   with pu^ do
   begin
      newzone:=pf_get_area(x,y);
      if(ukfly)or(ukfloater)
      then pfzone:=newzone
      else
        if(not pf_IfObstacleZone(newzone))then pfzone:=newzone;

      {$IFDEF _FULLGAME}
      unit_MiniMapXY(pu);
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_SetXY(pu:PTUnit;ax,ay:integer;movevxy:byte);
var _px,_py:integer;
begin
   with pu^ do
   begin
      _px:=x;
      _py:=y;
      x:=mm3(1,ax,map_mw);
      y:=mm3(1,ay,map_mw);
      if(x<>_px)or(y<>_py)then
      begin
         unit_UpdateXY(pu);
         if(_px=ua_x)
        and(_py=ua_y)then
        begin
           ua_x:=x;
           ua_y:=y;
        end;
      end;
      case movevxy of
mvxy_relative: begin
                  vx+=x-_px;
                  vy+=y-_py;
               end;
mvxy_strict  : begin
                  vx:=x;
                  vy:=y;
               end;
      end;
   end;
end;

procedure unit_reveal(pu:PTUnit;reset:boolean);
var t:byte;
begin
   with pu^ do
    with player^ do
    begin
       if(reset)then
       begin
          FillChar(vsnt,SizeOf(vsnt),0);
          FillChar(vsni,SizeOf(vsni),0);
       end;
       AddToInt(@vsnt[team],vistime);
       AddToInt(@vsni[team],vistime);

       if(revealed)then
        for t:=0 to MaxPlayers do
        begin
           AddToInt(@vsnt[t],fr_fps1);
           AddToInt(@vsni[t],fr_fps1);
        end;
    end;
end;
procedure unit_UpVision(pu:PTUnit);
var t:byte;
begin
   with pu^ do
    for t:=0 to MaxPlayers do
    begin
       if(vsnt[t]>0)then AddToInt(@vsnt[t],vistime);
       if(vsni[t]>0)then AddToInt(@vsni[t],vistime);
    end;
end;

procedure unit_clear_order(pu:PTUnit;clearid:boolean);
begin
   with pu^ do
   begin
      if(clearid)
      then ua_id:=ua_attack;

      ua_tar:=0;
      ua_x  :=x;
      ua_y  :=y;
      ua_bx :=-1;
   end;
end;
procedure units_clear_tar(tar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with _punits[u]^ do
       if(ua_tar=tar)then ua_tar:=0;
end;
procedure missiles_clear_tar(u:integer;ResetTarget:boolean);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with _missiles[i] do
     if(vstep>0)and(tar=u)then
     begin
        tar:=0;
        if(ResetTarget)then
        begin
           x:=vx;
           y:=vy;
           vstep:=1;
        end;
     end;
end;

procedure teleport_CalcReload(tu:PTUnit;limit:integer);
begin
   // tu - teleporter
   with tu^ do
    with player^ do reload:=integer(round(fr_fps1*limit/MinUnitLimit))*(teleport_SecPerLimit-mm3(0,upgr[upgr_hell_teleport],teleport_SecPerLimit));
end;

procedure unit_teleport(pu:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pu^ do
   begin
      tx:=mm3(0,tx,map_mw);
      ty:=mm3(0,ty,map_mw);
      {$IFDEF _FULLGAME}
      effect_teleport(vx,vy,tx,ty,ukfly,eidstart,eidend,snd);
      {$ENDIF}
      buff[ub_Teleport]:=fr_fps1;
      unit_SetXY(pu,tx,ty,mvxy_strict);
      unit_clear_order(pu,false);
      units_clear_tar(unum);
      missiles_clear_tar(unum,false);
      unit_UpVision(pu);
   end;
end;

procedure unit_zfall(pu:PTUnit);
var st:integer;
begin
   with pu^ do
   if(zfall<>0)then
   begin
      st:=sign(zfall);
      if(zfall>1)then st*=2;
      zfall-=st;
      unit_SetXY(pu,x,y+st,mvxy_relative);
   end;
end;

procedure unit_MoveSprite(pu:PTUnit);
begin
   if(ServerSide)then unit_zfall(pu);
   with pu^ do
   if(vx<>x)or(vy<>y)then
    if(IsUnitRange(transport,nil))then
    begin
       vstp:=0;
       vx  :=x;
       vy  :=y;
    end
    else
    begin
       if(vstp>UnitStepTicks)and(ServerSide)then vstp:=UnitStepTicks;
       if(vstp<=0)then vstp:=UnitStepTicks;
       vx  +=(x-vx) div vstp;
       vy  +=(y-vy) div vstp;
       vstp-=1;
    end;
end;

function unit_ability_UACScan(pu:PTUnit;scan_x,scan_y:integer;Check:boolean):boolean;
begin
   unit_ability_UACScan:=false;
   with pu^ do
    if(iscomplete)and(reload<=0)then
    begin
       unit_ability_UACScan:=true;
       if(Check)then exit;

       unit_clear_order(pu,true);
       ua_x:=scan_x;
       ua_y:=scan_y;
       reload :=radar_reload;
       buff[ub_Cast]:=fr_fps1;

       {$IFDEF _FULLGAME}
       if(ServerSide)and(player^.team=_players[UIPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
       {$ENDIF}
    end;
end;

function unit_ability_HInvuln(pu:PTUnit;target:integer;Check:boolean):boolean;
var tu:PTUnit;
begin
   // pu - caster
   // tu - target
   unit_ability_HInvuln:=false;
   if(IsUnitRange(target,@tu))then
   begin
      with tu^ do
       with uid^ do
        if(hits<=0)then exit;

      with pu^ do
       if(iscomplete)and(reload<=0)then
        with player^ do
         if(team=tu^.player^.team)and(upgr[upgr_hell_invuln]>0)and(tu^.buff[ub_Invuln]<=0)then
         begin
            unit_ability_HInvuln:=true;
            if(Check)then exit;

            tu^.buff[ub_Invuln]:=invuln_time;
            reload:=haltar_reload;
            upgr[upgr_hell_invuln]-=1;
            {$IFDEF _FULLGAME}
            effect_LevelUp(tu,EID_Invuln,nil);
            {$ENDIF}
         end;
   end;
end;

procedure unit_ability_UACStrike_Cast(pu:PTUnit);
begin
   with pu^ do
   begin
      missile_add(ua_x,ua_y,vx,vy,0,MID_Blizzard,playeri,uf_ground,uf_ground,false,0,dm_Blizzard);
      {$IFDEF _FULLGAME}
      effect_UACStrikeShot(pu);
      {$ENDIF}
   end;
end;

function unit_ability_UACStrike(pu:PTUnit;shot_x,shot_y:integer;Check:boolean):boolean;
var i:byte;
begin
   unit_ability_UACStrike:=false;
   with pu^ do
    if(iscomplete)and(reload<=0)then
     with player^ do
      if(upgr[upgr_uac_rstrike]>0)then
      begin
         unit_ability_UACStrike:=true;
         if(Check)then exit;

         unit_clear_order(pu,true);
         ua_x:=shot_x;
         ua_y:=shot_y;
         for i:=0 to MaxPlayers do AddToInt(@vsnt[i],fr_fps2);
         reload:=mstrike_reload;
         upgr[upgr_uac_rstrike]-=1;
         unit_ability_UACStrike_Cast(pu);
         buff[ub_Cast]:=fr_fps1;
      end;
end;



procedure _1c_push(tx,ty:pinteger;x0,y0,r0:integer);
var vx,vy,a:single;
begin
   vx :=x0-tx^;
   vy :=y0-ty^;
   a  :=sqrt(sqr(vx)+sqr(vy));
   if(a=0)then exit;
   vx :=vx/a;
   vy :=vy/a;
   tx^:=x0-trunc(r0*vx);
   ty^:=y0-trunc(r0*vy);
end;

procedure _2c_push(tx,ty:pinteger;x0,y0,r0,x1,y1,r1:integer);
var d:integer;
vx,vy,
  a,h:single;
begin
   r0+=1;
   r1+=1;
   d:=point_dist_int(x0,y0,x1,y1);
   if(abs(r0-r1)<=d)and(d<=(r0+r1))and(d>0)then
   begin
      a:=(sqr(r0)-sqr(r1)+sqr(d))/(2*d);
      h:=sqrt(sqr(r0)-sqr(a));

      vx:=(x1-x0)/d;
      vy:=(y1-y0)/d;

      if( trunc(-vy*(x0-tx^)+vx*(y0-ty^)) <= 0 )then
      begin
         tx^:=trunc( x0+a*vx-(h*vy) );
         ty^:=trunc( y0+a*vy+(h*vx) );
      end
      else
      begin
         tx^:=trunc( x0+a*vx+(h*vy) );
         ty^:=trunc( y0+a*vy-(h*vx) );
      end;
   end
   else _1c_push(tx,ty,x0,y0,r0);
end;

procedure _push_out(tx,ty,tr,ignore_unum:integer;newx,newy:pinteger;_ukfly,check_obstacles:boolean);
const nrl = 1;
var nrx,
    nry,
    nrd,
    nrt : array[0..nrl] of integer;
dx,dy,
o,u,d   : integer;

procedure add(ax,ay,ad,at:integer);
var i,n:integer;
begin
   // find insert i
   i:=0;
   while(i<=nrl)do
   begin
      if(ad<nrd[i])then break;
      i+=1;
   end;

   if(i>nrl)then exit;

   if(i<>nrl)then
    for n:=nrl-1 downto i do
    begin
       nrd[i+1]:=nrd[i];
       nrx[i+1]:=nrx[i];
       nry[i+1]:=nry[i];
       nrt[i+1]:=nrt[i];
    end;

   nrd[i]:=ad;
   nrx[i]:=ax;
   nry[i]:=ay;
   nrt[i]:=at;
end;

begin
   for u:=0 to nrl do
   begin
      nrd[u]:= NOTSET;
      nrx[u]:=-2000;
      nry[u]:=-2000;
      nrt[u]:=0;
   end;

   if(_ukfly)then check_obstacles:=false;

   if(check_obstacles)then
   begin
      tr-=bld_dec_mr;
      dx:=tx div dcw;
      dy:=ty div dcw;
      if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
       with map_dcell[dx,dy] do
        if(n>0)then
         for u:=0 to n-1 do
          with l[u]^ do
           if(r>0)and(t>0)then
           begin
              o:=tr+r;
              d:=point_dist_int(x,y,tx,ty)-o;
              add(x,y,d,o);
           end;
      tr+=bld_dec_mr;
   end;

   if(_ukfly=false)then
    for u:=1 to MaxCPoints do
     with g_cpoints[u] do
      if(cpCaptureR>0)and(cpNoBuildR>0)then
      begin
         o:=cpNoBuildR;
         d:=point_dist_int(cpx,cpy,tx,ty)-o;
         add(cpx,cpy,d,o);
      end;

   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
      if(hits>0)and(ukfly=_ukfly)and(unum<>ignore_unum)then
       if(speed<=0)or(not iscomplete)then
        if(not IsUnitRange(transport,nil))then
        begin
           o:=tr+_r;
           d:=point_dist_int(x,y,tx,ty);
           add(x,y,d-o,o);
        end;

   if(nrd[1]<=-1)
   then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],nrx[1],nry[1],nrt[1])
   else
     if(nrd[0]<=-1)
     then _2c_push(@tx,@ty,nrx[0],nry[0],nrt[0],-2000,-2000,-2000);

   newx^:=tx;
   newy^:=ty;
end;


procedure BuildingNewPlace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger);
var
aukfly  :boolean;
dx,dy,o,
u,sr,dr :integer;
begin
   with _uids[buid] do
   begin
      aukfly:=_ukfly;
      _push_out(tx,ty,_r+1,0,@tx,@ty,aukfly,(_players[pl].upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport));
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=NOTSET;
   dr:=NOTSET;
   for u:=1 to MaxUnits do
    with _units[u] do
     with uid^ do
      if(hits>0)and(speed<=0)and(ukfly=aukfly)and(iscomplete)and(playeri=pl)and(isbuildarea)then
       if(buid in ups_builder)and(not IsUnitRange(transport,nil))then
       begin
          o:=point_dist_int(x,y,tx,ty)-srange;
          if(o<dr)then
          begin
             dx:=x;
             dy:=y;
             dr:=o;
             sr:=srange;
          end;
       end;

   if(dr<NOTSET)then
   begin
      o :=point_dist_int(dx,dy,tx,ty);
      dr:=o-sr;
      if(0<dr)then _1c_push(@tx,@ty,dx,dy,sr-1);
   end;

   tx:=mm3(map_b0,tx,map_b1);
   ty:=mm3(map_b0,ty,map_b1);
   newx^:=tx;
   newy^:=ty;
end;


function CheckCollisionR(tx,ty,tr,skipunit:integer;building,flylevel,check_obstacles:boolean):byte;
var u,dx,dy:integer;
begin
   CheckCollisionR:=0;

   for u:=1 to MaxUnits do
    if(u<>skipunit)then
     with _punits[u]^ do
      with uid^ do
       if(hits>0)and(ukfly=flylevel)and(IsUnitRange(transport,nil)=false)then
        if(speed<=0)or(not iscomplete)then
         if(point_dist_int(x,y,tx,ty)<(tr+_r))then
         begin
            CheckCollisionR:=2;
            exit;
         end;

   if(flylevel)then exit;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)then
     begin
        if(building)
        then dx:=max2(cpsolidr,cpNoBuildR)
        else dx:=cpsolidr;
        if(dx<=0)then continue;
        if(point_dist_int(tx,ty,cpx,cpy)<dx)then
        begin
           CheckCollisionR:=3;
           exit;
        end;
     end;

   if(check_obstacles=false)then exit;

   tr-=bld_dec_mr;

   dx:=tx div dcw;
   dy:=ty div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for u:=0 to n-1 do
       with l[u]^ do
        if(r>0)and(t>0)then
         if(point_dist_int(x,y,tx,ty)<(tr+r))then
         begin
            CheckCollisionR:=4;
            exit;
         end;
end;

function CheckBuildArea(tx,ty,tr:integer;buid,pl:byte):byte;
var u:integer;
begin
   CheckBuildArea:=0;

   if(pl<=MaxPlayers)then
    with _players[pl] do
     if(n_builders<=0)then
     begin
        CheckBuildArea:=1; // no builders
        exit;
     end;

   if(tx<map_b0)or(map_b1<tx)
   or(ty<map_b0)or(map_b1<ty)then
   begin
      CheckBuildArea:=2;  // out of bounds
      exit;
   end;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)and(cpNoBuildR>0)then
      if(point_dist_int(tx,ty,cpx,cpy)<cpNoBuildR)then
      begin
         CheckBuildArea:=2;
         exit;
      end;

   tr+=_uids[buid]._r;

   CheckBuildArea:=2;

   for u:=1 to MaxUnits do
    with _punits[u]^ do
     with uid^ do
      if(hits>0)and(iscomplete)and(isbuildarea)and(playeri=pl)then
       if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)then
        if(buid in ups_builder)and(IsUnitRange(transport,nil)=false)then
         if(point_dist_int(x,y,tx,ty)<srange)then
         begin
            CheckBuildArea:=0; // inside build area
            break;
         end;
end;

function CheckBuildPlace(tx,ty,tr,uskip:integer;playern,buid:byte):byte;
var i:byte;
obstacles:boolean;
begin
   CheckBuildPlace:=0;

   {
   0 :  m_brushc:=c_lime;
   1 :  m_brushc:=c_red;
   2 :  m_brushc:=c_blue;
   else m_brushc:=c_gray;
   }
   obstacles:=true;
   if(playern<=MaxPlayers)then
   begin
      with _uids[buid] do
       with _players[playern] do
        obstacles:=(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);

      if(obstacles)and(_players[playern].state=ps_comp)then
        if(pf_IfObstacleZone(pf_get_area(tx,ty)))then begin CheckBuildPlace:=2;exit;end;
   end;


   i:=CheckBuildArea(tx,ty,0,buid,playern); // 0=inside; 1=outside; 2=no builders
   case i of
   0  : ;
   2  : begin CheckBuildPlace:=2;exit;end;
   else begin CheckBuildPlace:=3;exit;end;
   end;

   with _uids[buid] do
    i:=CheckCollisionR(tx,ty,tr+_r,uskip,_ukbuilding,_ukfly,obstacles);
   if(i>0)then CheckBuildPlace:=1;
end;


function unit_ability_HKeepBlink(pu:PTUnit;blink_x,blink_y:integer;Check:boolean):boolean;
var obstacles:boolean;
begin
   unit_ability_HKeepBlink:=false;
   with pu^ do
    if(hits>0)and(iscomplete)and(buff[ub_CCast]<=0)then
     with uid^ do
     with player^ do
      if(upgr[upgr_hell_HKTeleport]>0)then
      begin
         obstacles:=(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);
         _push_out(blink_x,blink_y,_r,unum,@blink_x,@blink_y,ukfly,obstacles);
         blink_x:=mm3(1,blink_x,map_mw);
         blink_y:=mm3(1,blink_y,map_mw);
         if(CheckCollisionR(blink_x,blink_y,_r,unum,_ukbuilding,ukfly,obstacles)>0)then exit;

         unit_ability_HKeepBlink:=true;
         if(Check)then exit;

         upgr[upgr_hell_HKTeleport]-=1;
         buff[ub_CCast]:=fr_fps1;

         case uidi of
         UID_HKeep : unit_teleport(pu,blink_x,blink_y{$IFDEF _FULLGAME},EID_HKeep_H ,EID_HKeep_S ,snd_cube{$ENDIF});
         UID_HAKeep: unit_teleport(pu,blink_x,blink_y{$IFDEF _FULLGAME},EID_HAKeep_H,EID_HAKeep_S,snd_cube{$ENDIF});
         end;
      end;
end;


function unit_ability_HTowerBlink(pu:PTUnit;blink_x,blink_y:integer;Check:boolean):boolean;
var obstacles:boolean;
begin
   unit_ability_HTowerBlink:=false;
   with pu^ do
    if(hits>0)and(iscomplete)and(buff[ub_CCast]<=0)then
     with uid^ do
     with player^ do
      if(upgr[upgr_hell_tblink]>0)then
      begin
         obstacles:=(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);
         if(srange<point_dist_int(x,y,blink_x,blink_y))then _1c_push(@blink_x,@blink_y,x,y,srange-1);
         _push_out(blink_x,blink_y,_r,unum,@blink_x,@blink_y,ukfly, obstacles  );
         blink_x:=mm3(1,blink_x,map_mw);
         blink_y:=mm3(1,blink_y,map_mw);
         if(point_dist_int(x,y,blink_x,blink_y)>srange)then exit;
         if(CheckCollisionR(blink_x,blink_y,_r,unum,_ukbuilding,ukfly,obstacles)>0)then exit;

         unit_ability_HTowerBlink:=true;
         if(Check)then exit;

         upgr[upgr_hell_tblink]-=1;
         buff[ub_CCast]:=fr_fpsd2;
         unit_teleport(pu,blink_x,blink_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
      end;
end;

function unit_ability_RevTeleport(pu:PTUnit;target,targetd:integer;Check:boolean):boolean;
var tu:PTUnit;
begin
   // pu - teleporter
   unit_ability_RevTeleport:=false;
   if(not IsUnitRange(target,@tu))then exit;

   with tu^ do
   with uid^ do
     if(_ukbuilding)
     or(not iscomplete)
     or(ukfly)
     or(hits<=0)
     or(buff[ub_Teleport]>0)
     or(pu^.playeri<>playeri)
     or(not pu^.iscomplete)
     or(pu^.hits<=0)
     then exit;

    with pu^  do
     with uid^ do
      with player^ do
       if(upgr[upgr_hell_rteleport]>0)then
       begin
          if(targetd=NOTSET)
          or(targetd<0     )then targetd:=point_dist_int(x,y,tu^.x,tu^.y);
          if(targetd>base_1r)then
            if(reload<=0)then
            begin
               unit_ability_RevTeleport:=true;
               if(Check)then exit;

               unit_teleport(tu,x,y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
               teleport_CalcReload(pu,tu^.uid^._limituse);
               tu^.ua_x  :=tu^.x;
               tu^.ua_y  :=tu^.y;
               tu^.ua_tar:=0;
            end;
       end;
end;

function ability_teleport(pu,tu:PTUnit;td:integer):boolean;
var tt:PTUnit;
    tr:integer;
begin
   // pu - target
   // tu - teleporter
   // td = dist2(pu,tu)
   if(td=NOTSET)then td:=point_dist_int(pu^.x,pu^.y,tu^.x,tu^.y);
   ability_teleport:=false;
   with pu^  do
    with uid^ do
      if(not _ukbuilding)and(iscomplete)and(ukfly=false)and(tu^.hits>0)and(tu^.iscomplete)then
       if(playeri=tu^.playeri)and(buff[ub_Teleport]<=0)then
        if(td<=tu^.uid^._r)then
        begin
           if(tu^.reload<=0)then
           begin
              if(not IsUnitRange(tu^.ua_tar,@tt))then exit;
              if(tu^.player^.team<>tt^.player^.team)then exit;
              if(tt^.hits<=0)then exit;

              if(ukfly=uf_ground)then
               if(pf_IfObstacleZone(tt^.pfzone))then exit;

              tu^.ua_x:=tt^.x;
              tu^.ua_y:=tt^.y;

              tr:=_r+tt^.uid^._r;

              if(ukfly=tt^.ukfly)
              then unit_teleport(pu,tu^.ua_x+(tr*sign(x-tu^.ua_x)),tu^.ua_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF})
              else unit_teleport(pu,tu^.ua_x                      ,tu^.ua_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});

              teleport_CalcReload(tu,_limituse);
              ability_teleport:=true;
           end;
        end
        else
          if(tu^.player^.upgr[upgr_hell_rteleport]>0)and(td>base_1r)then
           if(tu^.reload<=0)then
           begin
              unit_teleport(pu,tu^.x,tu^.y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
              teleport_CalcReload(tu,_limituse);
              ua_x  :=x;
              ua_y  :=y;
              ua_tar:=0;
              ability_teleport:=true;
           end
           else
           begin
              ua_x  :=x;
              ua_y  :=y;
              ability_teleport:=true;
           end;
end;


procedure unit_SetDefaults(pu:PTUnit;Client:boolean);
begin
   with pu^ do
   begin
      if(not Client)then
      begin
         transport:= 0;
         a_tar    := 0;
         a_weap   := 0;
      end;

      ua_id    := ua_attack;
      ua_tar   := 0;
      reload   := 0;
      pains    := 0;
      dir      := 270;
      group    := 0;
      a_reload := 0;
      a_shots  := 0;
      a_weap_cl:= 0;
      a_tar_cl := 0;
      a_exp    := 0;
      a_exp_next:=ExpLevel1;

      aiu_alarm_timer :=0;
      aiu_alarm_d     :=NOTSET;
      aiu_alarm_x     :=-1;
      aiu_alarm_y     :=0;
      aiu_need_detect :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
      aiu_FiledSquareNear  :=0;

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(pprod_e,SizeOf(pprod_e),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      wanim    := false;
      anim     := 0;
      unit_MiniMapXY  (pu);
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_PC_done_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  +=1;
      if(_isbarrack  )then
      begin
         n_barracks+=1;
         uprodm+=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths+=1;
         upprodm+=level+1;
      end;
   end;
end;
procedure unit_PC_done_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  -=1;
      if(_isbarrack  )then
      begin
         n_barracks-=1;
         uprodm-=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths-=1;
         upprodm-=level+1;
      end;
   end;
end;

procedure unit_PC_complete_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_x[uidi            ]<=0)then uid_x[uidi            ]:=unum;
      if(ucl_x[_ukbuilding,_ucl]<=0)then ucl_x[_ukbuilding,_ucl]:=unum;
      ucl_eb[_ukbuilding,_ucl]+=1;
      uid_eb[uidi            ]+=1;
      menergy+=_genergy;
      cenergy+=_genergy;
      unit_PC_done_inc(pu);
   end;
end;

procedure unit_PC_add_inc(pu:PTUnit;ubld,summoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      ucl_l[_ukbuilding     ]+=_limituse;
      uid_e[uidi            ]+=1;

      iscomplete:=ubld;

      if(iscomplete)
      then unit_PC_complete_inc(pu)
      else
      begin
         hits  := 1;
         cenergy-=_renergy;
         {$IFDEF _FULLGAME}
         if(playeri=UIPlayer)then SoundPlayAnoncer(snd_build_place[_urace],false,false);
         {$ENDIF}
      end;

      if(summoned)and(iscomplete)then
      begin
         buff[ub_Summoned]:=fr_fps1;
         {$IFDEF _FULLGAME}
         effect_UnitSummon(_LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_add(ux,uy,aunum:integer;ui,pl:byte;ubld,summoned:boolean;ulevel:byte):boolean;
var m,i:integer;
procedure _FindNotExistedUnit;
begin
   i:=MaxPlayerUnits*pl+1;
   m:=i+MaxPlayerUnits;
   while(i<m)do
   begin
      with _units[i] do
       if(hits<=dead_hits)then
       begin
          _LastCreatedUnit :=i;
          _LastCreatedUnitP:=_punits[i];
          break;
       end;
      i+=1;
   end;
end;
begin
   unit_add:=false;
   _LastCreatedUnit :=0;
   _LastCreatedUnitP:=_punits[0];
   with _players[pl] do
   begin
      if(ui=0)then exit;

      if(not IsUnitRange(aunum,nil))
      then _FindNotExistedUnit
      else
        if(_units[aunum].hits>dead_hits)
        then _FindNotExistedUnit
        else
        begin
           _LastCreatedUnit :=aunum;
           _LastCreatedUnitP:=@_units[_LastCreatedUnit];
        end;

      if(_LastCreatedUnit>0)then
      begin
         unit_add:=true;
         FillChar(_LastCreatedUnitP^,SizeOf(TUnit),0);

         with _LastCreatedUnitP^ do
         begin
            {$IFDEF _FULLGAME}
            mmap_order := _LastCreatedUnit mod vid_blink_period1;
            {$ENDIF}
            cycle_order:= _LastCreatedUnit mod order_period;
            unum       := _LastCreatedUnit;

            unit_SetXY(_LastCreatedUnitP,ux,uy,mvxy_strict);
            uidi    := ui;
            playeri := pl;
            player  :=@_players[playeri];
            ua_x    := x;
            ua_y    := y;
            ua_bx   := -1;
            ua_by   := -1;
            mv_x    := x;
            mv_y    := y;
            isselected     := false;
            transportC:= 0;

            FillChar(buff,sizeof(buff),0);
            FillChar(vsnt,SizeOf(vsnt),0);
            FillChar(vsni,SizeOf(vsni),0);

            if(ulevel>MaxUnitLevel)
            then ulevel:=MaxUnitLevel;
            level:=ulevel;

            unit_SetDefaults(_LastCreatedUnitP,false);
            unit_reveal     (_LastCreatedUnitP,false);
            unit_apllyUID   (_LastCreatedUnitP);
            unit_PC_add_inc (_LastCreatedUnitP,ubld,summoned);
         end;
      end;
   end;
end;

function StartBuild(bx,by:integer;buid,bp:byte):cardinal;
begin
   StartBuild:=_uid_conditionals(@_players[bp],buid);
   if(StartBuild=0)then
    with _players[bp] do
     if(CheckBuildPlace(bx,by,0,0,bp,buid)=0)
     then unit_add(bx,by,-1,buid,bp,false,false,0)
     else StartBuild:=ureq_place;
end;

function barrack_out_RStep(pu:PTUnit;_uid:byte):integer;
begin
   if(_uids[_uid]._ukfly=uf_fly)
   then barrack_out_RStep:=0
   else barrack_out_RStep:=pu^.uid^._r;//+_uids[_uid]._r;
end;

function barrack_out_unit(pu:PTUnit;_uid:byte;_sstep,_dir:integer):boolean;
var
cd    :single;
begin
   barrack_out_unit:=false;
   with pu^ do
   with uid^ do
   begin
      cd:=_dir*degtorad;

      if(_sstep<0)
      then _sstep:=barrack_out_RStep(pu,_uid);

      if(_sstep=0)
      then unit_add(x,y,-1,_uid,playeri,true,false,0)
      else unit_add(x+trunc(_sstep*cos(cd)),
                    y-trunc(_sstep*sin(cd)),-1,_uid,playeri,true,false,0);

      if(_LastCreatedUnit>0)then
      begin
         _LastCreatedUnitP^.ua_x  :=ua_x;
         _LastCreatedUnitP^.ua_y  :=ua_y;
         _LastCreatedUnitP^.ua_id :=ua_id;
         _LastCreatedUnitP^.ua_tar:=ua_tar;
         _LastCreatedUnitP^.dir   :=dir;

         if(_barrack_teleport)then
         begin
            _LastCreatedUnitP^.buff[ub_Teleport]:=fr_fps1;
            {$IFDEF _FULLGAME}
            if(SoundPlayUnit(snd_teleport,pu,nil))
            then effect_add(_LastCreatedUnitP^.vx,
                            _LastCreatedUnitP^.vy,SpriteDepth(_LastCreatedUnitP^.vy+1,_LastCreatedUnitP^.ukfly),EID_Teleport);
            {$ENDIF}
         end;
         barrack_out_unit:=true;
      end;
   end;

end;

procedure barrack_ProductionEnd(pu:PTUnit;_uid,count:byte);
var sstep,i  :integer;
    announcer:boolean;
begin
   with pu^ do
   with uid^ do
   begin
      dir  :=point_dir(x,y,ua_x,ua_y);
      sstep:=barrack_out_RStep(pu,_uid);

      announcer:=false;

      for i:=0 to count do announcer:=barrack_out_unit(pu,_uid,sstep,dir+i*15) or announcer;

      if(announcer)
      then GameLogUnitReady(_LastCreatedUnitP);
   end;
end;

//////   Start unit prod
//
function unit_ProdUnitStart_p(pu:PTUnit;puid,pn:byte):boolean;
begin
   unit_ProdUnitStart_p:=false;
   if(0<puid)and(puid<255)then
     with pu^ do
     with uid^ do
       if(hits>0)and(iscomplete)and(_isbarrack)then
         if not(puid in ups_units)
         then PlayerSetProdError(playeri,lmt_argt_unit,puid,ureq_barracks,pu)
         else
           if(uprod_r[pn]>0)
           then PlayerSetProdError(playeri,lmt_argt_unit,puid,ureq_busy,pu)
           else
             if(not PlayerSetProdError(playeri,lmt_argt_unit,puid,_uid_conditionals(pu^.player,puid),pu))then
               with player^ do
               begin
                  uproda+=1;
                  uprodl+=_uids[puid]._limituse;
                  uprodc[_uids[puid]._ucl]+=1;
                  uprodu[ puid           ]+=1;
                  cenergy-=_uids[puid]._renergy;
                  uprod_u[pn]:=puid;
                  uprod_r[pn]:=_uids[puid]._tprod;

                  unit_ProdUnitStart_p:=true;
               end;
end;
function unit_ProdUnitStart(pu:PTUnit;puid:byte):boolean;  // main function
var i:byte;
begin
   unit_ProdUnitStart:=true;

   for i:=0 to MaxUnitLevel do
   begin
      if(i>pu^.level)then break;
      if(unit_ProdUnitStart_p(pu,puid,i))then exit;
   end;

   unit_ProdUnitStart:=false;
end;
/// Stop unit prod
function unit_ProdUnitStop_p(pu:PTUnit;puid,pn:byte):boolean;
begin
   unit_ProdUnitStop_p:=false;
   with pu^ do
   with uid^ do
     if(uprod_r[pn]>0)and(iscomplete)and(_isbarrack)then
       if(puid=255)or(puid=uprod_u[pn])then
         with player^ do
         begin
            puid:=uprod_u[pn];

            uproda-=1;
            uprodl-=_uids[puid]._limituse;
            uprodc[_uids[puid]._ucl]-=1;
            uprodu[ puid           ]-=1;
            cenergy+=_uids[puid]._renergy;
            uprod_r[pn]:=0;

            unit_ProdUnitStop_p:=true;
         end;
end;
function unit_ProdUnitStop(pu:PTUnit;puid:byte;StopAll:boolean):boolean;
var i:byte;
begin
   unit_ProdUnitStop:=false;

   for i:=MaxUnitLevel downto 0 do
     if(unit_ProdUnitStop_p(pu,puid,i))then
     begin
        unit_ProdUnitStop:=true;
       if(not StopAll)then break;
     end;
end;


//////   Start upgrade production
//
function unit_ProdUpgrStart_p(pu:PTUnit;upid,pn:byte):boolean;
begin
   unit_ProdUpgrStart_p:=false;
   if(0<upid)and(upid<255)then
     with pu^ do
     with uid^ do
       if(hits>0)and(iscomplete)and(_issmith)then
         if not(upid in ups_upgrades)
         then PlayerSetProdError(playeri,lmt_argt_upgr,upid,ureq_smiths,pu)
         else
           if(pprod_r[pn]>0)
           then PlayerSetProdError(playeri,lmt_argt_upgr,upid,ureq_busy,pu)
           else
             if(not PlayerSetProdError(playeri,lmt_argt_upgr,upid,_upid_conditionals(player,upid),pu))then
               with player^ do
               with _upids[upid] do
               begin
                  upproda+=1;
                  upprodu[upid]+=1;
                  pprod_e[pn]:=_upid_energy(upid,upgr[upid]+1);
                  cenergy-=pprod_e[pn];
                  pprod_r[pn]:=_upid_time(upid,upgr[upid]+1);
                  pprod_u[pn]:=upid;

                  unit_ProdUpgrStart_p:=true;
               end;
end;
function unit_ProdUpgrStart(pu:PTUnit;upid:integer):boolean;
var i:byte;
begin
   unit_ProdUpgrStart:=true;

   for i:=0 to MaxUnitLevel do
   begin
      if(i>pu^.level)then break;
      if(unit_ProdUpgrStart_p(pu,upid,i))then exit;
   end;

   unit_ProdUpgrStart:=false;
end;
function unit_ProdUpgrStop_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   unit_ProdUpgrStop_p:=false;
   with pu^ do
   with uid^ do
     if(pprod_r[pn]>0)and(iscomplete)and(_issmith)then
       if(upid=255)or(upid=pprod_u[pn])then
         with player^ do
         begin
            upid:=pprod_u[pn];

            upproda-=1;
            upprodu[upid]-=1;
            cenergy+=pprod_e[pn]; //_upids[upid]._up_renerg;
            pprod_r[pn]:=0;

            unit_ProdUpgrStop_p:=true;
         end;
end;
function unit_ProdUpgrStop(pu:PTUnit;puid:byte;StopAll:boolean):boolean;
var i:byte;
begin
   unit_ProdUpgrStop:=false;

   for i:=MaxUnitLevel downto 0 do
     if(unit_ProdUpgrStop_p(pu,puid,i))then
     begin
        unit_ProdUpgrStop:=true;
        if(not StopAll)then break;
     end;
end;

procedure unit_PC_select_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]+=1;
      ucl_cs[_ukbuilding     ]+=1;
      uid_s [uidi            ]+=1;
      if(_isbuilder)then s_builders+=1;
      if(_isbarrack)then s_barracks+=1;
      if(_issmith  )then s_smiths  +=1;
   end;
end;
procedure unit_PC_select_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]-=1;
      ucl_cs[_ukbuilding     ]-=1;
      uid_s [uidi            ]-=1;
      if(_isbuilder)then s_builders-=1;
      if(_isbarrack)then s_barracks-=1;
      if(_issmith  )then s_smiths  -=1;
   end;
end;

procedure unit_UnSelect(pu:PTUnit);
begin
   with pu^ do
   begin
      if(isselected)then unit_PC_select_dec(pu);
      isselected:=false;
   end;
end;

procedure unit_PC_base_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_UnSelect(pu);

      if(iscomplete=false)
      then cenergy+=_uids[uidi]._renergy
      else
      begin
         unit_ProdUnitStop(pu,255,true);
         unit_ProdUpgrStop(pu,255,true);

         ucl_eb[_ukbuilding,_ucl]-=1;
         uid_eb[uidi            ]-=1;
         menergy-=_genergy;
         cenergy-=_genergy;

         unit_PC_done_dec(pu);
      end;

      if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure unit_PC_add_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army     -=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      ucl_l[_ukbuilding     ]-=_limituse;
      uid_e[uidi            ]-=1;
   end;
end;

procedure unit_ProdUnitEnd(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
     if(_isbarrack)then
       with player^ do
         for i:=0 to MaxUnitLevel do
           if(uprod_r[i]>0)then
           begin
              _uid:=uprod_u[i];

              if((army     +uproda)>MaxPlayerUnits)
              or((armylimit+uprodl)>MaxPlayerLimit)
              or(cenergy<0)
              or(uid_e[_uid]>=a_units[_uid])
              then
              else
                if(uprod_r[i]=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
                begin
                   barrack_ProductionEnd(pu,uprod_u[i],upgr[upgr_mult_product]);
                   unit_ProdUnitStop_p(pu,255,i);
                end
                else uprod_r[i]:=max2(1,uprod_r[i]-1*(upgr[upgr_fast_product]+1) );
           end;
end;

procedure unit_ProdUpgrEnd(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
     if(_issmith)then
       with player^ do
         for i:=0 to MaxUnitLevel do
           if(pprod_r[i]>0)then
           begin
              _uid:=pprod_u[i];
              if(cenergy<0)
              or(upgr[_uid]>=_upids[_uid]._up_max)
              or(upgr[_uid]>=a_upgrs[_uid])
              then
              else
                if(pprod_r[i]=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
                begin
                   upgr[_uid]+=1;
                   unit_ProdUpgrStop_p(pu,255,i);
                   GameLogUpgradeComplete(playeri,_uid,x,y);
                end
                else pprod_r[i]:=max2(1,pprod_r[i]-1*(upgr[upgr_fast_product]+1) );
           end;
end;

procedure ability_SpawnUnit(pu:PTUnit;tx,ty:integer;auid:byte);
var tu:PTUnit;
begin
   with pu^ do
   with player^ do
   begin
      if(not _uid_player_limit(player,auid))
      then _LastCreatedUnit:=0
      else
        if(not ServerSide)
        then _LastCreatedUnit:=1
        else unit_add(tx,ty,-1,auid,playeri,true,true,0);

      if(_LastCreatedUnit>0)then
      begin
         if(ServerSide)then
         begin
            _LastCreatedUnitP^.dir   :=dir;
            _LastCreatedUnitP^.a_tar :=a_tar;
            _LastCreatedUnitP^.ua_id :=ua_id;
            _LastCreatedUnitP^.ua_tar:=ua_tar;
            if(IsUnitRange(a_tar,@tu))then
            begin
               _LastCreatedUnitP^.ua_x :=tu^.x;
               _LastCreatedUnitP^.ua_y :=tu^.y;
            end
            else
             if(ua_x<>x)or(ua_y<>y)then
             begin
                _LastCreatedUnitP^.ua_x:=ua_x;
                _LastCreatedUnitP^.ua_y:=ua_y;
             end;
         end
         else _LastCreatedUnit:=0;
      end
      {$IFDEF _FULLGAME}
      else
        case auid of
UID_Phantom : effect_InPoint(tx,ty,SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
UID_LostSoul: effect_InPoint(tx,ty,SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
        end;
      {$ENDIF};
   end;
end;


procedure ability_SpawnUnitStep(pu:PTUnit;auid:byte);
var dd:integer;
begin
   with pu^ do
   with uid^ do
   begin
      dd:=_DIR360(dir+23) div 45;
      ability_SpawnUnit(pu,x+dir_stepX[dd]*_r,y+dir_stepY[dd]*_r,auid);
   end;
end;

function unit_CheckTransport(uu,tu:PTUnit):boolean;
begin
   //uu - transport
   //tu - target
   unit_CheckTransport:=false;
   if(tu^.ukfly=uf_fly)
   or(uu=tu)
   or(uu^.player<>tu^.player)then exit;

   if((uu^.transportM-uu^.transportC)>=tu^.uid^._transportS)then
     if(tu^.uidi in uu^.uid^.ups_transport)then unit_CheckTransport:=true;
end;

procedure unit_BaseCounters(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   begin
      for i:=0 to MaxUnitBuffs do
        if(0<buff[i])and(buff[i]<_ub_infinity)then buff[i]-=1;

      for i:=0 to MaxPlayers do
      begin
         if(0<vsnt[i])and(vsnt[i]<_ub_infinity)then vsnt[i]-=1;
         if(0<vsni[i])and(vsni[i]<_ub_infinity)then vsni[i]-=1;
      end;

      if(iscomplete)then
      begin
         if(  reload>0)then   reload-=1;
         if(a_reload>0)then a_reload-=1;
      end;
   end;
end;


procedure unit_detect(uu,tu:PTUnit;ud:integer);
var td:integer;
scan_buff:byte;
begin
   // tu - unit-detector
   // uu - unit-target
   scan_buff:=255;
   with uu^ do
   begin
      if(tu^.player^.observer)
      or((tu^.player^.upgr[upgr_fog_vision]>0)and(tu^.buff[ub_detect]<=0))
      then td:=0
      else
        if(tu^.uid^._ability=uab_UACScan)and(tu^.reload>radar_vision_time)then
        begin
           td:=point_dist_int(x,y,tu^.ua_x,tu^.ua_y);
           if(td<ud)
           then scan_buff:=ub_Scaned
           else td:=ud;
        end
        else td:=ud;

      if(td<=(tu^.srange+uid^._r))then
        if(buff[ub_Invis]<=0)then
        begin
           AddToInt(@vsnt[tu^.player^.team],vistime);
           if(scan_buff<=MaxUnitBuffs)and(player^.team<>tu^.player^.team)
           then AddToInt(@buff[scan_buff],vistime);
        end
        else
          if(tu^.buff[ub_Detect]>0)and(tu^.iscomplete)and(tu^.hits>0)then
          begin
             AddToInt(@vsnt[tu^.player^.team],vistime);
             AddToInt(@vsni[tu^.player^.team],vistime);
             if(scan_buff<=MaxUnitBuffs)and(player^.team<>tu^.player^.team)
             then AddToInt(@buff[scan_buff],vistime);
          end;
   end;
end;


procedure unit_remove(pu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       unit_PC_add_dec(pu);

       //if(G_Status=gs_running)then
        if(playeri>0)or(g_mode<>gm_invasion)then
         if(army<=0)and(state>ps_none){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         then GameLogPlayerDefeated(playeri);
    end;
end;

procedure unit_kill(pu:PTUnit;instant,fastdeath,buildcd,KillAllInside,suicide:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   if(hits>0)then
   with player^ do
   begin
      if(instant=false)then
      begin
         with uid^ do fastdeath:=(fastdeath)or(_fastdeath_hits>=0)or(_ukbuilding);
         buff[ub_Pain]:=fr_fps1; // prevent fast resurrecting

         if(not suicide)then GameLogUnitAttacked(pu);
         {$IFDEF _FULLGAME}
         effect_UnitDeath(pu,fastdeath,nil);
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      unit_PC_base_dec(pu);

      with uid^ do
      begin
         if(_ukbuilding)and(buildcd)then
           if(_ability<>uab_HellVision)or(not iscomplete)then build_cd:=min2(build_cd+step_build_reload,max_build_reload);
         zfall:=_zfall;
      end;

      x       :=vx;
      y       :=vy;
      unit_clear_order(pu,true);
      mv_x    :=x;
      mv_y    :=y;
      a_tar   :=0;
      a_reload:=0;
      reload  :=0;

      for i:=1 to MaxUnits do
      if(i<>unum)then
      begin
         tu:=@_units[i];
         if(tu^.hits>0)then
         begin
            if(tu^.ua_tar=unum)then tu^.ua_tar:=0;
            if(transportC>0)then
             if(tu^.transport=unum)then
             begin
                if(ukfly<>uf_ground)or(transport>0)or(KillAllInside)
                then unit_kill(tu,true,false,true,KillAllInside,suicide)
                else
                begin
                   tu^.transport:=0;
                   transportC-=tu^.uid^._transportS;
                   tu^.x+=_randomr(uid^._r);
                   tu^.y+=_randomr(uid^._r);
                   tu^.ua_x:=tu^.x;
                   tu^.ua_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)
                   then tu^.hits-=apc_exp_damage
                   else unit_kill(tu,true,false,true,false,suicide);
                end;
             end;
         end
         else tu^.transport:=0;
      end;
      missiles_clear_tar(unum,false);

      if(instant)then
      begin
         hits:=ndead_hits;
         unit_remove(pu);
      end
      else
      begin
         if(fastdeath)
         then hits:=fdead_hits
         else hits:=0;

         with uid^ do
         begin
            if(_death_missile>0)
            then missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);
            if(_death_uid>0)and(_death_uidn>0)then
              for i:=1 to _death_uidn do
                if(_uid_player_limit(player,_death_uid))then
                  unit_add(x-_randomr(_missile_r),y-_randomr(_missile_r),0,_death_uid,playeri,true,true,0);
         end;
      end;
   end
   else
     if(hits>dead_hits)then
     begin
        hits:=ndead_hits;
        unit_remove(pu);
     end;
end;

function unit_ability_HellVision(pu:PTUnit;target:integer;Check:boolean):boolean;
var tu:PTUnit;
begin
   unit_ability_HellVision:=false;
   // pu - caster
   // tu - target
   if(not IsUnitRange(target,@tu))then exit;
   with pu^     do
   with player^ do
     if(iscomplete)and(hits>0)and(reload<=0)and(tu^.iscomplete)and(tu^.hits>0)and(team=tu^.player^.team)then
       if(tu^.buff[ub_HVision]<fr_fps1)and(tu^.buff[ub_Detect]<=0)then
       begin
          unit_ability_HellVision:=true;
          if(Check)then exit;

          tu^.buff[ub_HVision]:=hell_vision_time;
          unit_kill(pu,false,true,false,false,true);
          {$IFDEF _FULLGAME}
          effect_LevelUp(tu,EID_Hvision,nil);
          {$ENDIF}
       end;
end;

procedure unit_Bonuses(pu:PTUnit);
var tu:PTUnit;
    t :integer;
procedure SetSRange(newsr:integer);
begin
   with pu^ do
   if(srange<>newsr)then
   begin
      srange:=newsr;
      {$IFDEF _FULLGAME}
      unit_CalcFogR(pu);
      {$ENDIF}
   end;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      speed:=_speed;
      // ABILITIES
      case _ability of
uab_Teleport      : level:=byte(upgr[upgr_hell_rteleport]>0);
uab_CCFly         : if(level>0)then
                    begin
                       if(ukfly<>uf_fly)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_CCup ,pu,nil);
                          {$ENDIF}
                          ukfly:=uf_fly;
                          zfall:=zfall-fly_hz;
                          if(ua_id<>ua_psability)
                          then unit_clear_order(pu,false);
                       end;
                       speed:=3;
                    end
                    else
                    begin
                       if(ukfly<>uf_ground)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_transport,pu,nil);
                          {$ENDIF}
                          zfall:=fly_hz;
                          ukfly:=uf_ground;
                          unit_clear_order(pu,false);
                       end;
                       speed:=0;

                       if(ServerSide)and(zfall<>0)then
                         if(CheckCollisionR(x,y+zfall,_r,unum,_ukbuilding,false, upgr[upgr_race_extbuilding[_urace]]=0 )>0)then
                         begin
                            level:=1;
                            buff[ub_CCast]:=fr_fps2;
                         end;
                    end;
      end;

      // DETECTION
      if(_detector)or(buff[ub_HVision]>0)
      then buff[ub_Detect]:=_ub_infinity
      else buff[ub_Detect]:=0;

      // INVIS
      case uidi of
UID_HEye          : buff[ub_Invis]:=b2ib[hits>_hhmhits];
UID_HTotem        : buff[ub_Invis]:=b2ib[upgr[upgr_hell_totminv]>0];
UID_Commando      : buff[ub_Invis]:=b2ib[upgr[upgr_uac_commando]>0];
UID_Demon         : buff[ub_Invis]:=b2ib[upgr[upgr_hell_spectre]>0];
UID_UMine         : buff[ub_Invis]:=_ub_infinity;
      end;

      // OTHER
      case uidi of
UID_UGTurret      : level:=byte(upgr[upgr_uac_plasmt]>0);
UID_Phantom,
UID_LostSoul      : begin
                       tu:=nil;
                       if(IsUnitRange(a_tar,@tu))and(a_reload>0)then buff[ub_CCast]:=fr_fpsd2;
                       if(buff[ub_pain]<=0)then
                         if(buff[ub_CCast]>0)and(tu<>nil)then ukfly:=tu^.ukfly else ukfly:=_ukfly;
                       ukfloater:=not ukfly;
                    end;
UID_UACDron       : begin
                    ukfloater:=upgr[upgr_uac_soaring]>0;
                    if(pf_IfObstacleZone(pfzone))and(ukfloater)
                    then begin if(speed= _speed)then speed:=_speed div 2;end
                    else begin if(speed<>_speed)then speed:=_speed;      end;
                    end;
UID_Demon         : begin
                    ukfloater:=upgr[upgr_hell_ghostm]>0;
                    if(pf_IfObstacleZone(pfzone))and(ukfloater)
                    then begin if(speed= _speed)then speed:=_speed div 2;{$IFDEF _FULLGAME}if(animw =_animw)then animw:=_animw div 2;{$ENDIF}end
                    else begin if(speed<>_speed)then speed:=_speed;      {$IFDEF _FULLGAME}if(animw<>_animw)then animw:=_animw;      {$ENDIF}end;
                    end;
UID_UTransport    : begin level:=min2(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+4*level;end;
UID_APC           : begin level:=min2(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+2*level;end;
      end;
      if(upgr[upgr_invuln]>0)then buff[ub_Invuln]:=fr_fps1;
      if(playeri=0)and(g_mode=gm_invasion)then
      begin
         ukfloater:=true;
         if(cycle_order<4 )
         or(cycle_order=11)
         or(cycle_order=21)then buff[ub_HVision]:=_ub_infinity else buff[ub_HVision]:=0;
         if(g_inv_wave_n>3)then
           if(cycle_order<2 )
           or(cycle_order=10)
           or(cycle_order=20)then buff[ub_Invis]:=_ub_infinity else buff[ub_Invis]:=0;
      end;

      // BUILD AREA
      case uidi of
UID_HEye          : isbuildarea:=true;
      else
      if(_isbuilder)then isbuildarea:=not ukfly;
      end;

      // SRANGE
      t:=_srange;
      if(_upgr_srange>0)and(_upgr_srange_step>0)
      then t+=upgr[_upgr_srange]*_upgr_srange_step;
      if(not _ukbuilding)
      then t+=upgr[upgr_race_unit_srange[_urace]]*upgr_race_srange_unit_bonus[_urace];
      SetSRange(t);
   end
   else
   begin
      SetSRange(_srange_min);
      if(hits>0)then
        case uidi of
UID_HEye          :  buff[ub_Invis]:=b2ib[hits>_hhmhits];
        end;
   end;
end;



