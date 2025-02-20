
procedure GameModeInvasionSpawnMonsters(limit,MaxMonsterLimit:longint);
function SpawnMonster(uid:byte):boolean;
var tx,ty:integer;
begin
   SpawnMonster:=false;
   if(limit<_uids[uid]._limituse)then exit;
   if(random(2)=0)then
   begin
      if(random(2)=0)
      then tx:=map_mw
      else tx:=0;
      ty:=random(map_mw);
   end
   else
   begin
      if(random(2)=0)
      then ty:=map_mw
      else ty:=0;
      tx:=random(map_mw);
   end;
   SpawnMonster:=_unit_add(tx,ty,0,uid,0,true,true,0);
   if(SpawnMonster)then limit-=_uids[uid]._limituse;
end;
function SpawnL(ul:longint):boolean;
begin
   SpawnL:=false;
   if(ul<=MaxMonsterLimit)then
    case ul of
ul12 :    SpawnL:=SpawnMonster(UID_Cyberdemon);
ul10 :    SpawnL:=SpawnMonster(UID_Mastermind);
ul4  : case random(4) of
       0 :SpawnL:=SpawnMonster(UID_Archvile);
       1 :SpawnL:=SpawnMonster(UID_Terminator);
       2 :SpawnL:=SpawnMonster(UID_Tank);
       3 :SpawnL:=SpawnMonster(UID_Flyer);
       end;
ul3  : case random(3) of
       0 :SpawnL:=SpawnMonster(UID_Baron);
       1 :SpawnL:=SpawnMonster(UID_Mancubus);
       2 :SpawnL:=SpawnMonster(UID_Arachnotron);
       end;
ul2  : case random(11) of
       0 :if(MaxMonsterLimit>ul2)then
          SpawnL:=SpawnMonster(UID_Demon);
       1 :SpawnL:=SpawnMonster(UID_Cacodemon);
       2 :SpawnL:=SpawnMonster(UID_Knight);
       3 :SpawnL:=SpawnMonster(UID_Revenant);
       4 :SpawnL:=SpawnMonster(UID_BFGMarine);
       5 :SpawnL:=SpawnMonster(UID_ZBFGMarine);
       6 :SpawnL:=SpawnMonster(UID_SSergant);
       7 :SpawnL:=SpawnMonster(UID_ZSSergant);
       8 :SpawnL:=SpawnMonster(UID_UACDron);
       9 :SpawnL:=SpawnMonster(UID_ZFPlasmagunner);
       10:SpawnL:=SpawnMonster(UID_FPlasmagunner);
       end;
else   case random(11) of
       0 :SpawnL:=SpawnMonster(UID_Imp);
       1 :SpawnL:=SpawnMonster(UID_Sergant);
       2 :if(MaxMonsterLimit>ul2)then
          SpawnL:=SpawnMonster(UID_Commando);
       3 :SpawnL:=SpawnMonster(UID_Antiaircrafter);
       4 :SpawnL:=SpawnMonster(UID_SiegeMarine);
       5 :SpawnL:=SpawnMonster(UID_ZSergant);
       6 :SpawnL:=SpawnMonster(UID_ZCommando);
       7 :SpawnL:=SpawnMonster(UID_ZAntiaircrafter);
       8 :SpawnL:=SpawnMonster(UID_ZSiegeMarine);
       9 :SpawnL:=SpawnMonster(UID_ZEngineer);
       10:if(MaxMonsterLimit>ul5)then
          SpawnL:=SpawnMonster(UID_Pain);
       end;
    end;
end;
function SpawnLR:boolean;
begin
   case random(6) of
   0 : SpawnLR:=SpawnL(ul1 );
   1 : SpawnLR:=SpawnL(ul2 );
   2 : SpawnLR:=SpawnL(ul3 );
   3 : SpawnLR:=SpawnL(ul4 );
   4 : SpawnLR:=SpawnL(ul10);
   5 : SpawnLR:=SpawnL(ul12);
   end;
end;
begin
   while(limit>=ul1)and(_players[0].army<MaxPlayerUnits)do
    if(not SpawnLR)then
     if(not SpawnL(ul12))then
      if(not SpawnL(ul10))then
       if(not SpawnL(ul4 ))then
        if(not SpawnL(ul3 ))then
         if(not SpawnL(ul2 ))then SpawnL(ul1);
end;
function WaveTime(base:integer):integer;
begin
   WaveTime:=base;
   WaveTime+=round(g_inv_wave_t_curr/fr_fps2*(MinSMapW/map_mw));
   WaveTime+=4*g_inv_wave_n;
end;

procedure GameModeInvasion;
const
max_wave_time_s = 150;
max_wave_time_t = fr_fps1*max_wave_time_s;
var i:byte;
begin
   if(_players[0].armylimit<=0)then
   begin
      if(g_inv_wave_t_next<=0)then
      begin
         if(g_inv_wave_n>=InvMaxWaves)
         then GameSetStatusWinnerTeam(1)
         else
         begin
            g_inv_wave_n+=1;
            case g_inv_wave_n of
            1  : g_inv_wave_t_next:=WaveTime(max_wave_time_s);
            10,
            19 : g_inv_wave_t_next:=120;
            else g_inv_wave_t_next:=WaveTime(60);
            end;
            g_inv_wave_t_next:=mm3(30,g_inv_wave_t_next,max_wave_time_s)*fr_fps1;
         end;
      end
      else
      begin
         g_inv_wave_t_next-=1;
         if(g_inv_wave_t_next=0)then
         begin
            {$IFDEF _FULLGAME}
            SoundPlayMMapAlarm(snd_teleport,false);
            {$ENDIF}
            case g_inv_wave_n of
            0  : g_inv_limit:=0;
            1  : g_inv_limit:=ul20;
            2  : g_inv_limit:=ul20*2;
            else g_inv_limit:=(g_inv_wave_n*g_inv_wave_n)*ul3+ul32;
            end;
            GameModeInvasionSpawnMonsters(g_inv_limit,(ul1*g_inv_wave_n));
            g_inv_wave_t_curr:=0;
         end;
      end;
   end
   else if(g_inv_wave_t_curr<max_wave_time_t)then g_inv_wave_t_curr+=1;
end;



