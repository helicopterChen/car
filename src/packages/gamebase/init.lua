--采用cc.load的方式模块化处理
local _M = {};
---------------------------------------------------------

--AppBase
_M.cAppBase  = import(".AppBase.cAppBase");
_M.cDataManager = import( ".AppBase.cDataManager" );
_M.cResLoader = import( ".AppBase.cResLoader" );
_M.cResManager = import( ".AppBase.cResManager" );
---------------------------------------------------------
--Avatar
---------------------------------------------------------
--CommonUtility
_M.CSVLoader				= import(".CommonUtility.CSVLoader");
_M.TableUtility				= import(".CommonUtility.TableUtility");
_M.TimeUtility				= import(".CommonUtility.TimeUtility" );
_M.cDataTableEx				= import(".CommonUtility.cDataTableEx");
_M.cDataQueue				= import( ".CommonUtility.cDataQueue" );
_M.BIT						= import( ".CommonUtility.Bit" );
---------------------------------------------------------
--Object
_M.cGameObject 				= import( ".Object.cGameObject" );
_M.cPropertiesManager 		= import( ".Object.cPropertiesManager" );
_M.cObjectManager			= import( ".Object.cObjectManager" );
_M.cServerObjectManager		= import( ".Object.cServerObjectManager" );
_M.cObjectContainer			= import( ".Object.cObjectContainer" );
---------------------------------------------------------
--Scene
_M.cSceneBaseClass			= import( ".Scene.cSceneBaseClass" );
_M.cSceneManager			= import( ".Scene.cSceneManager" );
---------------------------------------------------------
--Spell
---------------------------------------------------------
--UIUtility
_M.UILoaderEx				= import( ".UIUtility.UILoaderEx" );
_M.UIModifier				= import( ".UIUtility.UIModifier" );
_M.UIManager				= import( ".UIUtility.UIManager" );
_M.UIBaseClass				= import( ".UIUtility.UIBaseClass" );
---------------------------------------------------------
--VisualEffect
---------------------------------------------------------
--Net
_M.cNetMsgPacket 			= import( ".Network.cNetMsgPacket" );
_M.cNetConnection 			= import( ".Network.cNetConnection" );
_M.cNetConnectionManager 	= import( ".Network.cNetConnectionManager" );
_M.cNetFakeConnection 		= import( ".Network.cNetFakeConnection" );
_M.cNetFakeServer 			= import( ".Network.cNetFakeServer" );
_M.cNetFakeServerManager 	= import( ".Network.cNetFakeServerManager" );
---------------------------------------------------------
--Shader

return _M;
