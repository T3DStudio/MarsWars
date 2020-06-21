

procedure _unit_clfog(pu:PTUnit);
begin
   with (pu^) do
   begin
      fsr:=srng div fog_cw;
      if(fsr>MFogM)then fsr:=MFogM;
   end;
end;



procedure _CLData;

const
     btnhkeys1 : array[0..ui_p_btnsh,0..ui_p_lsecwi] of cardinal =
       ((SDLK_R, SDLK_T, SDLK_Y, SDLK_U, SDLK_I     ,SDLK_O    , SDLK_R, SDLK_T, SDLK_Y, SDLK_U),
        (SDLK_F, SDLK_G, SDLK_H, SDLK_J, SDLK_K     ,SDLK_L    , SDLK_F, SDLK_G, SDLK_H, SDLK_J),
        (SDLK_V, SDLK_B, SDLK_N, SDLK_M, SDLK_PERIOD,SDLK_COMMA, SDLK_V, SDLK_B, SDLK_N, SDLK_M));
     btnhkeys2 : array[0..ui_p_btnsh,0..ui_p_lsecwi] of cardinal =
       ((0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl),
        (0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl),
        (0, 0, 0, 0, 0, 0, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl, SDLK_LCtrl));
     btnhkeys: array[0..2,0..2] of cardinal =  ((SDLK_Q,SDLK_W,SDLK_E),
                                                (SDLK_A,SDLK_S,SDLK_D),
                                                (SDLK_Z,SDLK_X,SDLK_C));
     //SDLK_LESS, SDLK_GREATER
var i:byte;
  function btn2key(x,y:byte):cardinal;
  begin
     if(x<3)and(y<3)
     then btn2key:=btnhkeys[y,x]
     else btn2key:=0;
  end;
  procedure snd(advt:byte;sndt:byte;sndc:pMIX_CHUNK=nil;eid1:byte=0;eid2:byte=0;eids:pMIX_CHUNK=nil);
  var adv:boolean;
  begin
     with _tuids[i] do
     begin
        adv:=false;
        if(advt=1)then adv:=true;
        if(advt>1)then snd(1,sndt,sndc,eid1,eid2,eids);

        if(sndc<>nil)then   // sound
         if(_ueffsndn[adv,sndt]<MaxUIDSnds)then
         begin
            _ueffsnds[adv,sndt,_ueffsndn[adv,sndt]]:=sndc;
            inc(_ueffsndn[adv,sndt],1);
         end;
        if(eid1 >0  )then _ueffeid1[adv,sndt]:=eid1; // effect 1
        if(eid2 >0  )then _ueffeid2[adv,sndt]:=eid2; // effect 2
        if(eids<>nil)then _ueffeids[adv,sndt]:=eids; // effect sound
     end;
  end;
  procedure asnd(wp:byte;snd:pMIX_CHUNK;arld:integer=-1);
  begin
     with _tuids[i] do
     with _a_weap[wp] do
     begin
        aw_snd:=snd;
        if(arld=-3)then aw_rlda:= aw_rldt div 3;
        if(arld=-2)then aw_rlda:= aw_rldt div 2;
        if(arld=-1)then aw_rlda:=(aw_rldt div 3)*2;
        if(arld>-1)then aw_rlda:= aw_rldt;
     end;
  end;
  procedure csnd(snd:pMIX_CHUNK);
  begin
     with _tuids[i] do
      if(snd<>nil)then
       if(_com_sndn<MaxUIDSnds)then
       begin
          _com_snds[_com_sndn]:=snd;
          inc(_com_sndn,1);
       end;
  end;

begin
   with _tupids[up_hell_dattack] do begin _btnx:=0 ; _btny:=0 ; end;
   with _tupids[up_hell_mattack] do begin _btnx:=1 ; _btny:=0 ; end;
   with _tupids[up_hell_uarmor ] do begin _btnx:=0 ; _btny:=1 ; end;
   with _tupids[up_hell_barmor ] do begin _btnx:=0 ; _btny:=2 ; end;

   /////////////////////////////////////////////////////////////////////////////
   //
   // UPGRADES
   //

   with _tupids[up_hell_dattack] do begin _btnx:=0 ; _btny:=0 ; end;
   with _tupids[up_hell_mattack] do begin _btnx:=1 ; _btny:=0 ; end;
   with _tupids[up_hell_uarmor ] do begin _btnx:=0 ; _btny:=1 ; end;
   with _tupids[up_hell_barmor ] do begin _btnx:=0 ; _btny:=2 ; end;

   for i:=0 to 255 do
    with _tupids[i] do
    begin

       if(_ukey1=0)then
        if(_btnx<=ui_p_lsecwi)and(_btny<=ui_p_btnsh)then
        begin
           _ukey1:=btnhkeys1[_btny,_btnx];
           _ukey2:=btnhkeys2[_btny,_btnx];
        end;
    end;

   /////////////////////////////////////////////////////////////////////////////
   //
   // ORDERS
   //

   for i:=0 to 255 do
    with _toids[i] do
    begin
       _omarc:=c_white;
       if(i in [0,uo_upload,uo_prod,uo_uteleport])then _oidi:=uo_move;
       if(i in [uo_smove,uo_auto])then _oidi:=uo_stop;
       if(i = uo_spatrol)then _oidi:=uo_patrol;
    end;

   with _toids[uo_smove    ] do begin _obtnx:=255;_omarc:=c_lime;  end;
   with _toids[uo_spatrol  ] do begin _obtnx:=255;_omarc:=c_yellow;end;
   with _toids[uo_move     ] do begin _obtnx:=0;_obtny:=0; _obtn:=spr_b_move;   _okey1:=btn2key(_obtnx,_obtny); _omarc:=c_lime;    end;
   with _toids[uo_hold     ] do begin _obtnx:=1;_obtny:=0; _obtn:=spr_b_hold;   _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_patrol   ] do begin _obtnx:=2;_obtny:=0; _obtn:=spr_b_patrol; _okey1:=btn2key(_obtnx,_obtny); _omarc:=c_yellow;  end;
   with _toids[uo_attack   ] do begin _obtnx:=0;_obtny:=1; _obtn:=spr_b_attack; _okey1:=btn2key(_obtnx,_obtny); _omarc:=c_red;     end;
   with _toids[uo_stop     ] do begin _obtnx:=1;_obtny:=1; _obtn:=spr_b_stop;   _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_destroy  ] do begin _obtnx:=2;_obtny:=1; _obtn:=spr_b_delete; _okey1:=btn2key(_obtnx,_obtny);
                                                                                _okey2:=SDLK_LCtrl;
                                                                                _okey3:=SDLK_Delete;            end;
   with _toids[uo_upload   ] do begin _obtnx:=1;_obtny:=2; _obtn:=spr_b_upload; _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_unload   ] do begin _obtnx:=2;_obtny:=2; _obtn:=spr_b_unload; _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_rallpos  ] do begin _obtnx:=2;_obtny:=2; _obtn:=spr_b_ralpos; _okey1:=btn2key(_obtnx,_obtny); _omarc:=c_lime;    end;
   with _toids[uo_spawndron] do begin _obtnx:=0;_obtny:=2; _obtn:=_tuids[UID_Dron]._ubtn;
                                                                                _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_archresur] do begin _obtnx:=0;_obtny:=2; _obtn:=LoadBtnFS(spr_archvile[70].surf);
                                                                                _okey1:=btn2key(_obtnx,_obtny); end;
   with _toids[uo_botrepair] do begin _obtnx:=0;_obtny:=2; _obtn:=LoadBtnFS(spr_drone[11].surf);
                                                                                _okey1:=btn2key(_obtnx,_obtny); end;

   with _toids[uo_spawnlost] do begin _obtnx:=0;_obtny:=2; _obtn:=LoadBtnFS(spr_pain[23].surf);
                                                                                _okey1:=btn2key(_obtnx,_obtny); end;

   /////////////////////////////////////////////////////////////////////////////
   //
   // UNITS
   //

   for i:=0 to 255 do
    with _tuids[i] do
    begin
       _fr      := (_r div fog_cw)+1;
       _anims   := 0;
       _btnx    := 255;
       _btny    := 255;
       _sdpth   := 0;


       case i of
       UID_HKeep          : begin _btny:= 0;_btnx:=0; end;
       UID_HGate          : begin _btny:= 0;_btnx:=1; end;
       UID_HSymbol        : begin _btny:= 0;_btnx:=2; end;
       UID_HPools         : begin _btny:= 0;_btnx:=3; end;
       UID_HTower         : begin _btny:= 0;_btnx:=4; end;
       UID_HTeleport      : begin _btny:= 0;_btnx:=5; _sdpth:=-4;end;
       UID_HMonastery     : begin _btny:= 1;_btnx:=0; end;
       UID_HFortress      : begin _btny:= 1;_btnx:=1; end;
       UID_HTotem         : begin _btny:= 2;_btnx:=0; end;
       UID_HAltar         : begin _btny:= 2;_btnx:=1; _sdpth:=-3;end;

       UID_UCommandCenter : begin _btny:= 0;_btnx:=0; end;
       UID_UMilitaryUnit  : begin _btny:= 0;_btnx:=1; end;
       UID_UGenerator     : begin _btny:= 0;_btnx:=2; end;
       UID_UWeaponFactory : begin _btny:= 0;_btnx:=3; end;
       UID_UTurret        : begin _btny:= 0;_btnx:=4; _anims:=3; end;
       UID_URadar         : begin _btny:= 0;_btnx:=5; end;
       UID_UVehicleFactory: begin _btny:= 1;_btnx:=0; end;
       UID_UPTurret       : begin _btny:= 2;_btnx:=0; end;
       UID_URTurret       : begin _btny:= 2;_btnx:=1; end;
       UID_URocketL       : begin _btny:= 2;_btnx:=2; end;


//                                                                    DEATH                           PAIN                          CREATE                        MELEE ATTACK           DISTANCE ATTACK
       UID_Imp            : begin _btny:= 0;_btnx:=0; _anims  := 11;  snd(2 ,ueff_death ,snd_impd1  );snd(2,ueff_pain  ,snd_z_p   );snd(2,ueff_create,snd_impc1 );asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);
                                                                      snd(2 ,ueff_death ,snd_impd2  );snd(2,ueff_create,snd_impc2 );
                                                                      snd(2 ,ueff_fdeath,nil,EID_Gavno,0,snd_meat);                 end;
       UID_LostSoul       : begin _btny:= 0;_btnx:=1;                 snd(2 ,ueff_death ,snd_pexp   );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_d0    );asnd(0,snd_d0     ,-2);                       end;
       UID_Demon          : begin _btny:= 0;_btnx:=2; _anims  := 14;  snd(2 ,ueff_death ,snd_demond );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_demonc);asnd(0,snd_demona ,-2);                       end;
       UID_Cacodemon      : begin _btny:= 0;_btnx:=3;                 snd(2 ,ueff_death ,snd_cacod  );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_cacoc );asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);end;
       UID_Knight         : begin _btny:= 0;_btnx:=4; _anims  := 11;  snd(0 ,ueff_death ,snd_knightd);snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_knight);asnd(1,snd_hmelee ,-2);asnd(0,snd_hshoot ,-2);
                                                                      snd(1 ,ueff_death ,snd_barond );                              end; //snd_baron
       UID_Cyberdemon     : begin _btny:= 0;_btnx:=5; _anims  := 10;  snd(2 ,ueff_death ,snd_cyberd );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_cyberc);                       asnd(0,snd_launch ,-2);end;
       UID_Mastermind     : begin _btny:= 1;_btnx:=0; _anims  := 10;  snd(2 ,ueff_death ,snd_mindd  );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_mindc );                       asnd(0,snd_shotgun,-2);end;
       UID_Pain           : begin _btny:= 1;_btnx:=1; _anims  := 6 ;  snd(2 ,ueff_death ,snd_pain_d );snd(2,ueff_pain  ,snd_pain_p);snd(2,ueff_create,snd_pain_c);                       asnd(0,snd_d0     ,-2);end;
       UID_Revenant       : begin _btny:= 1;_btnx:=2; _anims  := 14;  snd(2 ,ueff_death ,snd_rev_d  );snd(2,ueff_pain  ,snd_z_p   );snd(2,ueff_create,snd_rev_c );asnd(1,snd_rev_m  ,-2);asnd(0,snd_rev_a  ,-2);end;
       UID_Mancubus       : begin _btny:= 1;_btnx:=3; _anims  := 9 ;  snd(2 ,ueff_death ,snd_man_d  );snd(2,ueff_pain  ,snd_man_p );snd(2,ueff_create,snd_man_c );                       asnd(0,snd_man_a  , 0);end;
       UID_Arachnotron    : begin _btny:= 1;_btnx:=4; _anims  := 10;  snd(2 ,ueff_death ,snd_ar_d   );snd(2,ueff_pain  ,snd_dpain );snd(2,ueff_create,snd_ar_c  );                       asnd(0,snd_plasmas, 0);end;
       UID_Archvile       : begin _btny:= 1;_btnx:=5; _anims  := 15;  snd(2 ,ueff_death ,snd_arch_d );snd(2,ueff_pain  ,snd_arch_p);snd(2,ueff_create,snd_arch_c);asnd(1,snd_meat   ,-2);asnd(0,snd_arch_a ,-2);end;

       UID_ZFormer        : begin _btny:= 2;_btnx:=0; _anims  := 17; end;
       UID_ZSergant       : begin _btny:= 2;_btnx:=1; _anims  := 17; end;
       UID_ZCommando      : begin _btny:= 2;_btnx:=2; _anims  := 14; end;
       UID_ZBomber        : begin _btny:= 2;_btnx:=3; _anims  := 13; end;
       UID_ZMajor         : begin _btny:= 2;_btnx:=4; _anims  := 14; end;
       UID_ZBFG           : begin _btny:= 2;_btnx:=5; _anims  := 13; end;



       UID_Dron           : begin                                    snd(2 ,ueff_fdeath,nil,EID_Exp,0,snd_exp);snd(2,ueff_create,snd_dron0 );
                                                                                                               snd(2,ueff_create,snd_dron1 );
                                                                     asnd(0,snd_cast2 ,-2);end;
       UID_Sergant        : begin _btny:= 0;_btnx:=0; _anims  := 17; end;
       UID_Commando       : begin _btny:= 0;_btnx:=1; _anims  := 14; end;
       UID_Medic          : begin _btny:= 0;_btnx:=2; _anims  := 17; end;
       UID_Bomber         : begin _btny:= 0;_btnx:=3; _anims  := 13; end;
       UID_Major          : begin _btny:= 0;_btnx:=4; _anims  := 13; end;
       UID_BFG            : begin _btny:= 0;_btnx:=5; _anims  := 13; end;
       UID_Scout          : begin{_btny:= 0;_btnx:=7;}_anims  := 17; end;
       UID_FAPC           : begin _btny:= 1;_btnx:=0;                end;
       UID_APC            : begin _btny:= 1;_btnx:=1; _anims  := 17; end;
       UID_Terminator     : begin _btny:= 2;_btnx:=0; _anims  := 13; end;
       UID_Tank           : begin _btny:= 2;_btnx:=1; _anims  := 17; end;
       UID_Flyer          : begin _btny:= 2;_btnx:=2;                end;

       UID_Mine           : begin _sdpth:=-2; end;
       end;

       case i of
       UID_ZFormer,
       UID_ZSergant,
       UID_ZCommando,
       UID_ZBomber,
       UID_ZMajor,
       UID_ZBFG      : begin
                          snd(2,ueff_create,snd_z_s1);snd(2,ueff_death ,snd_z_d1);                snd(2,ueff_pain  ,snd_z_p );
                          snd(2,ueff_create,snd_z_s2);snd(2,ueff_death ,snd_z_d2);
                          snd(2,ueff_create,snd_z_s3);snd(2,ueff_death ,snd_z_d3);
                                                      snd(2,ueff_fdeath,nil,EID_Gavno,0,snd_meat);
                       end;
       UID_Scout,
       UID_Medic,
       UID_Sergant,
       UID_Commando,
       UID_Bomber,
       UID_Major,
       UID_BFG       : begin
                          snd(2,ueff_create,snd_uac_u0);csnd(snd_uac_u0);snd(2,ueff_death,snd_ud1);
                          snd(2,ueff_create,snd_uac_u1);csnd(snd_uac_u1);snd(2,ueff_death,snd_ud2);
                          snd(2,ueff_create,snd_uac_u2);csnd(snd_uac_u2);snd(2,ueff_fdeath,nil,EID_Gavno,0,snd_meat);
                       end;
       UID_FAPC,
       UID_APC,
       UID_Terminator,
       UID_Tank,
       UID_Flyer     : begin
                          snd(2,ueff_create,snd_uac_u0);csnd(snd_uac_u0);
                          snd(2,ueff_create,snd_uac_u1);csnd(snd_uac_u1);
                          snd(2,ueff_create,snd_uac_u2);csnd(snd_uac_u2);
                          snd(2,ueff_fdeath,nil,EID_Exp2,0,snd_exp);
                       end;
       end;

       case i of
       UID_Imp          : csnd(snd_imp);
       UID_LostSoul,
       UID_Demon,
       UID_Cacodemon,
       UID_Knight,
       UID_Cyberdemon,
       UID_Mastermind,
       UID_Pain         : csnd(snd_demon1);
       UID_Revenant     : csnd(snd_rev_ac);
       UID_ZFormer,
       UID_ZSergant,
       UID_ZCommando,
       UID_ZBomber,
       UID_ZMajor,
       UID_ZBFG,
       UID_Mancubus     : csnd(snd_zomb);
       UID_Arachnotron  : csnd(snd_ar_act);
       UID_Archvile     : csnd(snd_arch_a);
       end;

       case _urace of
       r_hell : if(_itbuild)then
                begin
                   snd(2,ueff_startb,snd_cubes);
                   if(_r<=45 )
                   then snd(2,ueff_fdeath,snd_exp2,EID_BExp ,EID_db_h1,nil)
                   else snd(2,ueff_fdeath,snd_exp2,EID_BBExp,EID_db_h0,nil);
                end
                else snd(2,ueff_startb,snd_teleport);
       r_uac  : if(_itbuild)then
                begin
                   snd(2,ueff_startb,snd_ubuild);
                   if(_r<=45 )
                   then snd(2,ueff_fdeath,snd_exp2,EID_BExp ,EID_db_u1,nil)
                   else snd(2,ueff_fdeath,snd_exp2,EID_BBExp,EID_db_u0,nil);
                end
                else snd(2,ueff_startb,snd_teleport);
       end;

       case i of
       UID_Cyberdemon : begin _foota:=30;snd(2,ueff_foot,snd_cyberf); end;
       UID_Arachnotron: begin _foota:=28;snd(2,ueff_foot,snd_ar_f  ); end;
       UID_Mastermind : begin _foota:=22;snd(2,ueff_foot,snd_mindf ); end;
       end;

       if(_ukey1=0)then
        if(_btnx<=ui_p_lsecwi)and(_btny<=ui_p_btnsh)then
        begin
           _ukey1:=btnhkeys1[_btny,_btnx];
           _ukey2:=btnhkeys2[_btny,_btnx];
        end;

       if(_ukey1=0)
       then _ukeyc:=''
       else
       begin
          _ukeyc:=UpperCase(GetKeyName(_ukey1));
          case _ukey2 of
          SDLK_LCtrl : _ukeyc:='Ctr+'+_ukeyc;
          SDLK_LShift: _ukeyc:='Sft+'+_ukeyc;
          SDLK_LAlt  : _ukeyc:='Alt+'+_ukeyc;
          0          : ;
          else
             _ukeyc:='???+'+_ukeyc;
          end;
       end;
    end;

end;


procedure _LoadUIPanelBTNs;
var iu,it:byte;
begin
   _CLData;

   FillChar(ui_UIPBTNS,SizeOf(ui_UIPBTNS),0);  // units/buildings/upgrades
   FillChar(ui_UIMBTNS,SizeOf(ui_UIMBTNS),0);  // quick select pannel
   FillChar(ui_UIABTNS,SizeOf(ui_UIABTNS),0);  // orders/abilities

   for iu:=0 to 255 do
   begin
      with _tuids[iu] do
       if(_btnx<=ui_p_lsecwi)and(_btny<=ui_p_btnsh)then
        if(_urace in [1..race_n])then
        begin
           if(_itbuild)
           then it:=0
           else it:=1;

           ui_UIPBTNS[_btnx,_btny,it,_urace]:=iu;
        end;

      with _tupids[iu] do
      begin
         if(_btnx<=ui_p_lsecwi)and(_btny<=ui_p_btnsh)then
          if(_urace in [1..race_n])then ui_UIPBTNS[_btnx,_btny,2,_urace]:=iu;

         _upbtn:=_dsurf;
      end;

      with _toids[iu] do _obtn:=_dsurf;
   end;


   // quick select pannel
   ui_UIMBTNS[r_hell,0,0]:=UID_HKeep;
   ui_UIMBTNS[r_hell,1,0]:=UID_HTeleport;
   ui_UIMBTNS[r_hell,0,1]:=UID_HMonastery;
   ui_UIMBTNS[r_hell,1,1]:=UID_HAltar;

   ui_UIMBTNS[r_uac ,0,0]:=UID_Dron;
   ui_UIMBTNS[r_uac ,1,0]:=UID_URadar;
   ui_UIMBTNS[r_uac ,0,1]:=UID_UVehicleFactory;
   ui_UIMBTNS[r_uac ,1,1]:=UID_URocketL;


   for iu:=0 to 255 do
    with _toids[iu] do
     if(_okey1=0)
     then _okeyc:=''
     else
     begin
        _okeyc:=UpperCase(GetKeyName(_okey1));
        case _okey2 of
      SDLK_LCtrl : _okeyc:='Ctr+'+_okeyc;
      SDLK_LShift: _okeyc:='Sft+'+_okeyc;
      SDLK_LAlt  : _okeyc:='Alt+'+_okeyc;
        0        : ;
        else       _okeyc:='???+'+_okeyc;
        end;
        if(_okey3>0)then _okeyc:=_okeyc+' '+UpperCase(GetKeyName(_okey3))
     end;


   for iu:=0 to 255 do
    with _tuids[iu] do
     for it:=1 to 255 do
      if(it in _orders)then
       with _toids[it] do
        if(_obtn<>_dsurf)then
        begin
           if(it=uo_upload)and(_apcm=0)then continue;
           if(_obtnx<=ui_p_rsecwi)and(_obtny<=ui_p_btnsh)then ui_UIABTNS[iu,_obtnx,_obtny]:=it;
        end;
end;

