
type


////////////////////////////////////////////////////////////////////////////////
//
//   BASIC
//

TSoc        = set of char;
PTSoc       = ^TSoc;
TSob        = set of byte;
PTSob       = ^TSob;

{$IFDEF _FULLGAME}

string6     = string[6];

////////////////////////////////////////////////////////////////////////////////
//
//   GRAPHIC
//

TMWPixel = cardinal;
TMWColor = cardinal;{record
   r,g,
   b,a       : byte;
end; }
PTMWColor = ^TMWColor;
//PPTMWColor = ^TMWColor;

TMWTexture = record
   sdlsurface: pSDL_Surface;
   sdltexture: pSDL_Texture;
    w, h,
   hw,hh     : integer;
end;
PTMWTexture = ^TMWTexture;
PPTMWTexture = ^PTMWTexture;

TMWTextureList  = array of pTMWTexture;
PTMWTextureList = ^TMWTextureList;

//  SPRITE MODEL

TMWSModelType = (
smt_effect,               // simple missile or effect
smt_missile,              // missile with direction
smt_buiding,
smt_turret,
smt_turret2,
smt_lost,                 //UID_Lost
smt_imp,                  //UID_Imp,UID_Demon,UID_ZFormer,UID_ZSergant,UID_ZBomber,UID_ZBFG,UID_Baron,UID_Cyberdemon:
smt_zengineer,            //UID_ZEngineer
smt_zcommando,            //UID_ZCommando
smt_fmajor,               //UID_Majot,UID_ZMajor
smt_caco,                 //UID_Cacodemon
smt_mmind,                //UID_Mastermind
smt_pain,                 //UID_Pain
smt_revenant,             //UID_Revenant
smt_mancubus,             //UID_Mancubus
smt_archno,               //UID_Arachnotron
smt_arch,                 //UID_ArachVile
smt_apc,                  //UID_APC
smt_fapc,                 //UID_FAPC
smt_marine0,              //UID_Engineer,UID_Sergant,UID_Bomber,UID_BFG
smt_medic,                //UID_Medic
smt_commando,             //UID_Commando
smt_tank,                 //UID_Tank
smt_terminat,             //UID_Terminator
smt_transport,            //UID_Transport
smt_flyer,                //UID_FLyer
smt_effect2              // simple missile or effect
);

//  SPRITE MODEL STATES

TMWSModelState = (
sms_none,
sms_walk,
sms_stand,
sms_pain,
sms_cast,
sms_dready,
sms_dattack,
sms_mattack,
sms_death,
sms_build
);

TMWSModel = record
   sm_list  : TMWTextureList;
   sm_sel_hw,
   sm_sel_hh,
   sm_listi,   // last value
   sm_listn : integer;
   sm_type  : TMWSModelType;
end;
PTMWSModel = ^TMWSModel;

TMWTileSet  = array[0..MaxTileSet] of pTMWTexture;
PTMWTileSet = ^TMWTileSet;

TFont = record
   MWTextures: array[char] of pTMWTexture;
   font_w,
   font_h,
   font_hw,
   font_hh,
   font_lh   : integer;
end;
PTFont = ^TFont;

TEID = record
   eid_anim_smstate: TMWSModelState;
   eid_smodel      : PTMWSModel;
   eid_smask_color : TMWColor;
   eid_smask_alpha : byte;
end;

TEffect = record
   e_eid      : byte;
   e_x,
   e_y,
   e_z,
   e_depth,
   e_anim_i,
   e_anim_last_i,
   e_anim_step,
   e_anim_last_i_t
            : integer;
end;

TUIItem = record
   kind     : byte;
   sprite   : PTMWTexture;
   cx,cy,
   x0,y0,
   x1,y1    : integer;
   color    : TMWColor;
   text_lt,
   text_lt2,
   text_rt,
   text_rd,
   text_ld  : string6;
end;

TVSprite = record
   sprite    : PTMWTexture;
   x,y,
   depth,
   shadowz   : integer;
   shadow_color,
   aura_color: TMWColor;
   alpha     : byte;
end;
PTVSprite = ^TVSprite;

 TIntList = array of integer;
PTIntList = ^TIntList;

TThemeDecorAnim = record
   tda_xo,
   tda_yo,
   tda_shadow,
   tda_anext,
   tda_atime:integer
end;
PTThemeDecorAnim = ^TThemeDecorAnim;
TThemeDecorAnimL = array of TThemeDecorAnim;

TAlarm = record
   al_x,
   al_y,
   al_mx,
   al_my,
   al_r,
   al_t       : integer;
   al_v       : byte;
   al_c       : TMWColor;
end;

TMenuItem = record
   mi_x0,mi_y0,
   mi_x1,mi_y1: integer;
   mi_enabled : boolean;
end;
PTMenuItem = ^TMenuItem;

TMenuListItem = record
   mli_value  : integer;
   mli_caption: shortstring;
   mli_enabled: boolean;
end;

TPlayerColorArray  = array[0..LastPlayer] of TMWColor;

TAlignment = (ta_LU,   // |^| | |
              ta_MU,   // | |^| |
              ta_RU,   // | | |^|
              ta_LM,   // |-| | |
              ta_MM,   // | |-| |
              ta_RM,   // | | |-|
              ta_LD,   // |_| | |
              ta_MD,   // | |_| |
              ta_RD,   // | | |_|
              ta_chat, // special
              ta_MMR );// |  |- |

// theme edge terrain style
TThemeEdgeTerrainStyle = (tes_fog,tes_nature,tes_tech,tes_none);

////////////////////////////////////////////////////////////////////////////////
//
//   SOUNDS
//

TMWSoundSource = record
   ssrc_source   :TALuint;
   ssrc_volumeVar:psingle;
end;
PTMWSoundSource   = ^TMWSoundSource;
TMWSoundSourceSet = record
   sss_list: array of TMWSoundSource;
   sss_size: integer;
end;
PTMWSoundSourceSet = ^TMWSoundSourceSet;

TMWSound = record
   s_sound  : TALuint;
end;
PTMWSound = ^TMWSound;

TSoundSet = record
   snds_list : array of PTMWSound;
   snds_size,
   snds_cur  : integer;
end;
PTSoundSet = ^TSoundSet;

////////////////////////////////////////////////////////////////////////////////
//
//   MAP
//

TMapTerrainGridCellDecor = record
   tgca_decorTime,
   tgca_decorDepth,
   tgca_decorX,
   tgca_decorY,
   tgca_decorN     : integer;
   tgca_decorS     : PTMWTexture;
   tgca_decorA     : PTThemeDecorAnim;
end;
TMapTerrainGridCellDecal = record
   tgca_decalX,
   tgca_decalY     : integer;
   tgca_decalS     : PTMWTexture;
end;

TMapTerrainGridCellAnim = record
   tgca_decorstep   : byte;
   tgca_tile_liquid,
   tgca_tile_crater,
   tgca_decor_n,
   tgca_decal_n    : integer;
   tgca_decor_l    : array of TMapTerrainGridCellDecor;
   tgca_decal_l    : array of TMapTerrainGridCellDecal;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   OTHER
//

TInputKeyType = (ikt_keyboard,ikt_mouseb,ikt_mousew);

TInputKey = record
   ik_type  : TInputKeyType;
   ik_value : cardinal;
   ik_timer_twice,
   ik_timer_pressed
            : integer;
   ik_depend: byte;
end;

TTab3PageType = (t3pt_none=0,t3pt_controls,t3pt_observer,t3pt_replay);

TTabType      = (tt_buildings=0,tt_units,tt_upgrades,tt_controls);
const
i2tab         : array[ord(low(TTabType))..ord(high(TTabType))] of TTabType = (tt_buildings,tt_units,tt_upgrades,tt_controls);

type
TVidPannelPos = (vpp_left=0,vpp_right,vpp_top,vpp_bottom);
const
VPPSet_Vertical   = [vpp_left,vpp_right ];
VPPSet_Horizontal = [vpp_top ,vpp_bottom];
type

TUIUnitHBarsOption= (uhb_damaged,uhb_always,uhb_selected);

TPlayersColorSchema = (pcs_default=0,pcs_LYR,pcs_WYR,pcs_WAR,pcs_teams,pcs_wTeams);

//Ti2
TSaveLoadItem = record
   data_p:pointer;
   data_s:cardinal;
end;

TArrayOfsString = array of shortstring;
PTArrayOfsString = ^TArrayOfsString;

TServerInfo = record
   ip       : cardinal;
   port     : word;
   info     : shortstring;
end;

TReplayPos = record
   rp_fpos : int64;
   rp_gstep: cardinal;
end;

THotKeyTable  = array[0..HotKeysArraySize] of cardinal;
pTHotKeyTable = ^THotKeyTable;

TPanelHintTable  = array[0..HotKeysArraySize] of shortstring;
pTPanelHintTable = ^TPanelHintTable;

TUnitList = record
   ulist_n    : integer;
   ulist_luid : array of byte;
   ulist_lunum: array of integer;
end;
pTUnitList = ^TUnitList;

TUnitGroup = record
   ugroup_n,
   ugroup_d,
   ugroup_x,
   ugroup_y   : integer;
   ugroup_uids: array[boolean] of TSoB;
end;
pTUnitGroup = ^TUnitGroup;

{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//
//   GAME
//

TCheckCollisionR = (cbr_no,cbr_mapSide,cbr_unit,cbr_cpoint,cbr_obstacle);
TCheckBuildArea  = (cba_inBuildArea,cba_noBuilders,cba_NoBuildArea,cba_outBuildArea);
TCheckBuildPlace = (cbp_good,cbp_noplace,cbp_out,cbp_unknown);

TPoint = record
   p_x,
   p_y   :integer;
end;
TMapGridPFDomainData = record
   nextDomain,
   edgeCells_n: word;
   edgeCells_l: array of TPoint;
end;
PTMapGridPFDomainData = ^TMapGridPFDomainData;

TMapTerrainGridCell = record
   tgc_solidlevel: byte;
   tgc_pf_solid  : boolean;
   tgc_pf_zone,
   tgc_pf_domain : word;
end;

TUnitAbilityType = (uat_passive,uat_notarget,uat_point,uat_unit);
TUnitAbility = record
   ua_type    : TUnitAbilityType;       // 0-passive, 1-no target, 2-need to go point and self cast, 3-point/unit target require
   ua_morphUID,   // if >0 then ability - transformation to uid
   ua_rupgr,
   ua_rupgrl,
   ua_ruid    : byte;
   {$IFDEF _FULLGAME}
   ua_mbrush_c: TMWColor;
   ua_mbrush_r: integer;
   ua_btn     : PTMWTexture;
   ua_name,
   ua_descr   : shortstring;
   {$ENDIF}
end;

TDamageMod = array[0..MaxDamageModFactors] of record
  dm_factor : integer;  // 100 = x1
  dm_flags  : cardinal;
end;

TMID = record
   mid_base_damage,
   mid_base_splashr,
   mid_size,
   mid_speed       : integer;
   mid_noflycheck,
   mid_teamdamage  : boolean;
   mid_ystep,
   mid_homing      : byte;
   mid_nodamage    : TSoB;

   {$IFDEF _FULLGAME}
   ms_smodel       : PTMWSModel;
   ms_eid_fly_st   : integer;
   ms_eid_target_eff,
   ms_eid_fly,
   ms_eid_decal    : byte;
   ms_eid_death,
   ms_eid_death_cnt,
   ms_eid_death_r,
   ms_snd_death_ch : array[false..true] of byte;
   ms_snd_death    : array[false..true] of PTSoundSet;
   {$ENDIF}
end;

TMissile = record
   x,y,
   vx,vy,
   damage,
   vstep,hvstep,
   tar,
   dir,
   mtars,
   dtars    : integer;
   player,
   homing,
   dmod,
   mid      : byte;
   fake,
   mfe,mfs  : boolean;
   {$IFDEF _FULLGAME}
   ms_eid_bio_death: boolean;
   {$ENDIF}
end;

TWUDataTime  = array[1..MaxUnits] of cardinal;
TWCPDataTime = array[1..MaxCPoints] of byte;

TUWeapon = record
  aw_type,
  aw_tarprior,
  aw_fakeshots,
  aw_rupgr,
  aw_rupgr_l,
  aw_ruid,
  aw_dupgr,
  aw_oid      : byte;
  aw_uids     : TSob;
  aw_tarf,
  aw_reqf     : cardinal;
  aw_x,
  aw_y,
  aw_dupgr_s,
  aw_max_range,
  aw_min_range,
  aw_count    : integer;
  aw_dmod,
  aw_reload   : byte;
  aw_rld_s    : TSoB;
  {$IFDEF _FULLGAME}
  aw_rld_a    : TSoB;
  aw_snd_target,
  aw_snd_shot,
  aw_snd_start: PTSoundSet;
  aw_eid_target_onlyshot:boolean;
  aw_eid_target,
  aw_eid_shot,
  aw_eid_start: byte;
  aw_AnimStay : TMWSModelState;
  {$ENDIF}
end;

TUID = record
   _square,
   _hmhits,
   _hhmhits,
   _mhits       : longint;
   _speed,
   _r,_missile_r,
   _srange,
   _srange_min,
   _renergy,
   _genergy,
   _btime,
   _bstep,
   _tprod,
   _painc,
   _painc_upgr_step,
   _zfall,
   _transportS,
   _transportM,
   _base_armor,
   _baseregen,
   _zombie_hits,
   _upgr_srange_step,
   _limituse,
   _level_damage,
   _level_armor
                : integer;

   _upgr_srange,
   _upgr_armor,
   _upgr_regen,
   _rebuild_uid,
   _rebuild_level,
   _rebuild_ruid,
   _rebuild_rupgr,
   _rebuild_rupgrl,
   _zombie_uid,
   _death_missile,
   _death_missile_dmod,
   _death_uid,
   _death_uidn,
   _urace,
   _ucl,
   _ruid1,
   _ruid1n,
   _ruid2,
   _ruid2n,
   _ruid3,
   _ruid3n,
   _rupgr,
   _rupgrl      : byte;

   _a_BonusRangeAntiFly,
   _a_BonusRangeAntiGround,
   _a_BonusRangeAntiBuilding,
   _a_BonusRangeAntiUnit
                : integer;
   _a_weap      : array[0..MaxUnitWeapons] of TUWeapon;

   _attack,
   _ability_rNoObstacles
                : boolean;
   _ability,
   _ability_rupgr,
   _ability_rupgrl,
   _ability_ruid: byte;
   _barrack_teleport,
   _slowturn,
   _ukbuilding,
   _ukmech,
   _uklight,
   _detector,
   _isbuilder,
   _issmith,
   _isbarrack,
   _issolid,
   _ukfly,
   _splashresist: boolean;
   _fastdeath_hits
                : integer;

   _shcf        : single;

   ups_builder,
   ups_units,
   ups_upgrades,
   ups_transport      : TSoB;
   {$IFDEF _FULLGAME}
   _mmr,
   _animw,
   _animd,
   _fr          : integer;
   un_btn,
   un_sbtn      : TMWTexture;
   un_smodel    : array[0..MaxUnitLevel] of PTMWSModel;

   un_txt_name,
   un_txt_udescr,
   un_txt_fdescr,
   un_txt_uihint1,
   un_txt_uihint2,
   un_txt_uihint3,
   un_txt_uihint4,
   un_txt_uihintS
                : shortstring;

   un_build_amode,
   un_eid_bcrater
                : byte;
   un_eid_bcrater_y,
   un_foot_anim : integer;

   un_eid_summon_spr
                : array[0..MaxUnitLevel] of PTMWTexture;
   un_eid_summon,
   un_eid_death,
   un_eid_fdeath,
   un_eid_pain
                : array[0..MaxUnitLevel] of byte;

   un_eid_snd_foot,
   un_eid_snd_summon,
   un_eid_snd_death,
   un_eid_snd_fdeath,
   un_eid_snd_pain,

   un_snd_ready, //command sounds
   un_snd_move,
   un_snd_attack,
   un_snd_annoy,
   un_snd_select
                : PTSoundSet;
   {$ENDIF}
end;
PTUID = ^TUID;
TUPID = record  // upgrade
   _up_ruid1,
   _up_ruid2,
   _up_ruid3,
   _up_rupgr,
   _up_btni,
   _up_race     : byte;
   _up_renerg,
   _up_renerg_xpl, // energy * per level
   _up_renerg_apl, // energy + per level
   _up_time,
   _up_time_xpl,
   _up_time_apl,
   _up_max      : integer;
   _up_mfrg     : boolean;

   {$IFDEF _FULLGAME}
   _up_btn      : pTMWTexture;
   _up_name,
   _up_descr,
   _up_hint     : shortstring;
   {$ENDIF}
end;

TAIAlarm = record
   aia_enemy_base
                : boolean;
   aia_enemy_limit
                : longint;
   aia_x,
   aia_y        : integer;
   aia_zone     : word;
end;

TLogMes = record
   mtype,
   argt,
   argx         : byte;
   str          : shortstring;
   xi,yi        : integer;
   tick         : cardinal;
end;
PTLogMes = ^TLogMes;

TPlayer = record
   name    : shortstring;

   team,
   race ,slot_race,
   player_type,
   pnum    : byte;

   build_cd,
   army,
   cenergy,
   menergy : integer;
   armylimit
           : longint;

   isdefeated,
   isobserver,
   isrevealed,
   isready : boolean;

   o_id    : byte;
   o_a0,
   o_x0,o_y0,
   o_x1,o_y1
           : integer;

   ucl_e,                                        // existed class
   ucl_eb,                                       // existed class iscomplete=true and hits>0
   ucl_s,
   ucl_x   : array[false..true,byte] of integer; // first unit class

   uid_e,
   uid_eb,
   uid_s,
   uid_x   : array[byte] of integer;

   ucl_c,                                        // count buildings/units
   ucl_cs  : array[false..true] of integer;      // count selected buildings/units
   ucl_l   : array[false..true] of longint;      // limit buildings/units

   uprodl  : longint;                            // current limit in production
   uprodm,                                       // current max unit productions
   uproda  : integer;                            // current productions
   uprodc  : array[byte] of integer;
   uprodu  : array[byte] of integer;

   upprodm,
   upproda : integer;
   upprodu,
   upgr    : array[byte] of byte;

   a_upgrs,
   a_units : array[byte] of integer;
   a_builders: integer;


   ai_max_ulimit,
   ai_maxcount_energy,
   ai_maxcount_mains,
   ai_maxcount_unitps,
   ai_maxcount_upgrps,
   ai_maxcount_tech0,
   ai_maxcount_tech1,
   ai_maxcount_tech2,
   ai_maxlimit_detect,
   ai_maxcount_spec1,
   ai_maxcount_spec2,
   ai_maxcount_towers,
   ai_mincount_towers,
   ai_maxlimit_blimit,
   ai_max_specialist,
   ai_attack_limit,
   ai_attack_delay,
   ai_scout_u_cur,
   ai_scout_u_cur_w,
   ai_scout_u_new,
   ai_scout_u_new_w,
   ai_detection_pause
           : integer;
   ai_maxcount_upgrlvl
           : byte;
   ai_hptargets
           : TSoB;
   ai_skill: byte;
   ai_flags: cardinal;
   ai_alarms
           : array[0..LastPlayer] of TAIAlarm;
   ai_attack_timer,
   ai_scout_timer
           : integer;
   ai_ReadyForAttack
           : boolean;


   s_builders,
   s_barracks,
   s_smiths,
   n_builders,
   n_barracks,
   n_smiths
           : integer;

   PNU     : byte;
   n_u,
   net_ttl : word;
   net_ip  : cardinal;
   net_port: word;

   prod_error_cndt: cardinal;
   prod_error_utp,
   prod_error_uid : byte;
   prod_error_x,
   prod_error_y   : integer;

   net_logsend_pause
           : integer;
   log_l   : array[0..MaxPlayerLog] of TLogMes;
   log_i,
   log_n,
   log_n_cl
           : cardinal;

   log_EnergyCheck
           : integer;
end;
PTPlayer = ^TPlayer;
TPList = array[0..LastPlayer] of TPLayer;

TUnitVisionData = array[0..LastPlayer] of integer;

TMoveXY = (mvxy_none,mvxy_relative,mvxy_strict);

TUnit = record
   hits     : longint;
   vx,vy,
   x,y,
   gridx,gridy,
   zfall,
   srange,
   speed,dir,
   reload,vstp,
   unum     : integer;

   zone     : word;

   level,
   cycle_order,
   group,
   playeri,
   uidi     : byte;

   uprod_r,
   pprod_r,
   pprod_e  : array[0..MaxUnitLevel] of integer;
   uprod_u,
   pprod_u  : array[0..MaxUnitLevel] of byte;

   a_exp,
   a_exp_next,
   a_shots  : cardinal;
   a_reload,
   a_weap_cl,
   a_weap   : byte;
   a_tar,
   a_tar_cl,

   ua_bx,ua_by,
   ua_x ,ua_y,
   ua_tar
            : integer;
   ua_id    : byte;


   moveDest_x,
   moveDest_y    // unit destination map xy
            : integer;

   movePF_direct
            : boolean;
   movePFDest_x,
   movePFDest_y, // pf destination map xy
   movePFDest_cx,
   movePFDest_cy,// pf destination grid xy
   movePFPos_cx,
   movePFPos_cy, // pf unit position grid xy
   movePFNext_x,
   movePFNext_y
            : integer;
   movePF_d1,
   movePF_dx: word;

   transport,
   pains,
   transportM,
   transportC
            : integer;

   buff     : array[0..MaxUnitBuffs] of integer;

   TeamDetection,
   TeamVision     : TUnitVisionData;

   WaitForNextTarget:byte;
   ukfly,
   isbuildarea,
   ukfloater,
   iscomplete,
   solid,
   isselected: boolean;

   aiu_FiledSquareNear,
   aiu_limitaround_ally,
   aiu_limitaround_enemy,
   aiu_need_detect
            : longint;
   aiu_alarm_timer,
   aiu_alarm_d,
   aiu_alarm_x,
   aiu_alarm_y
            : integer;

   {$IFDEF _FULLGAME}
   anim_isMoving
            : boolean;

   animw,
   mmx,mmy,
   fx,fy,fsr,
   anim,animf,
   shadow
            : integer;
   lvlstr_w,  // weapon upgrades
   lvlstr_r,  // reload
   lvlstr_b,  // buffs
   lvlstr_l,  // level
   lvlstr_a,  // armor
   lvlstr_s   // other upgrs
            : string6;
   mmap_TickOrder
            : byte;
   {$ENDIF}

   player   : PTPlayer;
   uid      : PTUID;
end;
PTUnit = ^TUnit;
PPTUnit = ^PTUnit;

TCTPoint = record
   cpx ,cpy ,
   cpsolidr,cpCaptureR,cpNoBuildR,
   cp_ToCenterD,
   cpmx,cpmy,cpmr,
   cpenergy,
   cpCaptureTime,
   cpTimer      : integer;
   cplifetime   : cardinal;
   cpTimerOwnerTeam,
   cpTimerOwnerPlayer,
   cpOwnerPlayer,
   cpOwnerTeam  : byte;
   cpZone       : word;
   cpunitst_pstate,
   cpUnitsTeam,
   cpunitsp_pstate,
   cpUnitsPlayer: array[0..LastPlayer] of longint;
end;
PTCTPoint = ^TCTPoint;

TMapPreset = record
   mapp_name    : shortstring;
   mapp_seed    : cardinal;
   mapp_psize    : integer;
   mapp_type,
   mapp_symmetry,
   mapp_scenario: byte;

   mapp_player_team
                : array[0..LastPlayer] of byte;
end;



