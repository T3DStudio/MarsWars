

procedure cmp_Init;
var x:byte;
begin
   for x:=0 to LastMission do cmp_mmap[x]:=spr_c_phobos;

   cmp_mmap[0 ]:=spr_c_hell;
   cmp_mmap[1 ]:=spr_c_phobos;
   cmp_mmap[2 ]:=spr_c_phobos;
   cmp_mmap[3 ]:=spr_c_deimos;
   cmp_mmap[4 ]:=spr_c_deimos;
   cmp_mmap[5 ]:=spr_c_deimos;
   cmp_mmap[6 ]:=spr_c_mars;
   cmp_mmap[7 ]:=spr_c_mars;
   cmp_mmap[8 ]:=spr_c_mars;
   cmp_mmap[9 ]:=spr_c_earth;
   cmp_mmap[10]:=spr_c_earth;
   cmp_mmap[11]:=spr_c_earth;

   cmp_mmap[12]:=spr_c_phobos;
   cmp_mmap[13]:=spr_c_phobos;
   cmp_mmap[14]:=spr_c_phobos;
   cmp_mmap[15]:=spr_c_deimos;
   cmp_mmap[16]:=spr_c_deimos;
   cmp_mmap[17]:=spr_c_deimos;
   cmp_mmap[18]:=spr_c_hell;
   cmp_mmap[19]:=spr_c_hell;
   cmp_mmap[20]:=spr_c_hell;
   cmp_mmap[21]:=spr_c_mars;
   cmp_mmap[22]:=spr_c_mars;
   cmp_mmap[23]:=spr_c_mars;
end;
procedure cmp_ClearPStarts;
var i:byte;
begin
   for i:=0 to MaxPlayers do
   begin
      map_psx[i]:=-5000;
      map_psy[i]:=-5000;
   end;
end;
procedure cmp_SetPStart(p:byte;px,py:integer);
begin
   map_psx[p]:=px;
   map_psy[p]:=py;
end;
procedure cmp_SetPStartMir(p1,p2:byte);
begin
   map_psx[p1]:=map_mw-map_psx[p2];
   map_psy[p1]:=map_mw-map_psy[p2];
end;
procedure cmp_FillPStartsCircle(pstart,pnum:byte;cx,cy,cr,cd:integer);
var p:byte;
dstep,
ddir :integer;
begin
   if(pnum<1)or(pnum>MaxPlayers)then exit;

   dstep:=round(360/pnum);
   ddir :=cd;

   for p:=1 to pnum do
   begin
      map_psx[pstart]:=cx+round(cr*cos(ddir*DEGTORAD));
      map_psy[pstart]:=cy+round(cr*sin(ddir*DEGTORAD));
      ddir  +=dstep;
      pstart+=1;
      if(pstart>MaxPlayers)then break;
   end;
end;
procedure cmp_SetPlayer(p,r,t:byte);
begin
   with g_players[p] do
   begin
      state:=t;
      race :=r;
      if(p=HPlayer)then name:=PlayerName;
   end;
end;
procedure cmp_CreateUnit(playeri:byte;ux,uy:integer;uuid:byte);
begin
   unit_add(ux,uy,0,uuid,playeri,true,false,0);
end;

procedure cmp_StartMission;
begin
   cmp_data_b1:= 0;
   cmp_data_b2:= 0;
   cmp_data_b3:= 0;
   cmp_data_c1:= 0;

   g_deadobservers:=false;
   case cmp_sel of
0  : begin
        g_mode      :=gm_scirmish;
        g_generators:=0;
        map_seed    :=666;
        map_mw      :=4000;
        map_obs     :=4;
        map_symmetry:=false;
        map_vars;

        HPlayer :=1;
        UIPlayer:=1;

        cmp_SetPlayer(HPlayer,r_hell,ps_play);
        cmp_SetPlayer(4      ,r_uac ,ps_comp);

        cmp_ClearPStarts;
        cmp_SetPStart(1,map_mw div 4,map_mw div 3);
        cmp_SetPStartMir(4,1);

        cmp_CreateUnit(HPlayer,map_psx[HPlayer],map_psy[HPlayer],UID_HKeep);

        cmp_CreateUnit(4,map_psx[4]-150,map_psy[4]-150,UID_UCommandCenter);
        cmp_CreateUnit(4,map_psx[4]+150,map_psy[4]+150,UID_UPortal);

        PlayerSetAllowedUnits(HPlayer,[ UID_HGate,UID_HSymbol1..UID_HSymbol4,UID_HPools,UID_HTower,
                                        UID_Imp,UID_Demon], MaxUnits,true);
     end;
   end;

   Map_premap(true);
   MoveCamToPoint(map_psx[HPlayer],map_psy[HPlayer]);
end;

procedure cmp_MissionCode;
var i:integer;
begin
   case cmp_sel of
0  : begin
        // tutorial stages, subtasks
        with g_players[HPlayer] do
        begin
           {if(menergy<2000)
           then cmp_data_b1:=1
           else
             if(menergy<2000)}

        end;
        if(g_players[4].ucl_e[true,0]=0)then GameSetStatusWinnerTeam(g_players[HPlayer].team);

     end;
   end;
end;

