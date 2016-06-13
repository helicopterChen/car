local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local CCSUILoader = import("framework.cc.uiloader.CCSUILoader")
local CCSSceneLoader = import("framework.cc.uiloader.CCSSceneLoader")

local UIPanel = cc.ui.UIPanel

function UIPanel:ctor(options)
	self.subControl = {}
end

function UIPanel:autoAdaptSize( parentSize )
	local options = self.options
	local jsonNode = self.jsonNode
	if options == nil or jsonNode == nil then
		return
	end
	local sizeChange = false
	local sName = options.name
	local fillMode = string.sub( sName, -12, -1 )
	local width = parentSize.width
	local height = parentSize.height
	local nOY = 0
	if fillMode == ".FILL_SCREEN" then
		width = CONFIG_SCREEN_WIDTH
		height = CONFIG_SCREEN_HEIGHT
		sizeChange = true
	elseif fillMode == ".FILL_PARENT" then
		width = parentSize.width
		height = parentSize.height
		sizeChange = true
	elseif fillMode == ".FILL_MAINLY" then
		width = parentSize.width
		height = parentSize.height
		nOY = -65
		sizeChange = true
	end
	if sizeChange == true then
		self:setSize( width, height )
		self:setPosition( CCPoint( 0, nOY ) )
		--Èç¹ûÊÇÆÕÍ¨µÄ¿Ø¼þ£¬Ôò½øÐÐÏàÓ¦µÄÎ»ÖÃ´¦Àí
		self:modifyPanelChildPos_( "Panel", true, self:getContentSize(), jsonNode.children)
	end
	for i, v in ipairs( jsonNode.children ) do
		local childNode = ccuiloader_seekNodeEx( self, v.options.name )
		if childNode ~= nil then
			if v.classname ~= "ScrollView" then
				if v.classname ~= "Panel" then
					self:updatePosByOptions( childNode, v )
				else
					childNode:autoAdaptSize( self:getContentSize() )
				end
			end
		end
	end
end

function UIPanel:updatePosByOptions( uiNode, jsonNode )
	local options = jsonNode.options
	if options ~= nil then
		uiNode:setPositionX(options.x or 0)
		uiNode:setPositionY(options.y or 0)
		uiNode:setAnchorPoint( cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))
	end
end



function UIPanel:modifyPanelChildPos_(clsType, bAdaptScreen, parentSize, children)
	if "Panel" ~= clsType
		or not bAdaptScreen
		or not children then
		return
	end

	self:modifyLayoutChildPos_(parentSize, children)
end

function UIPanel:modifyLayoutChildPos_(parentSize, children)
	for _,v in ipairs(children) do
		self:calcChildPosByName_(children, v.options.name, parentSize)
	end
end

function UIPanel:calcChildPosByName_(children, name, parentSize)
	local child = self:getPanelChild_(children, name)
	if not child then
		return
	end
	if child.posFixed_ then
		return
	end

	local layoutParameter
	local options
	local x, y
	local bUseOrigin = false

	options = child.options
	layoutParameter = options.layoutParameter

	if not layoutParameter then
		return
	end

	if 1 == layoutParameter.type then
		if 1 == layoutParameter.gravity then
			-- left
			x = options.width * 0.5
		elseif 2 == layoutParameter.gravity then
			-- top
			y = parentSize.height - options.height * 0.5
		elseif 3 == layoutParameter.gravity then
			-- right
			x = parentSize.width - options.width * 0.5
		elseif 4 == layoutParameter.gravity then
			-- bottom
			y = options.height * 0.5
		elseif 5 == layoutParameter.gravity then
			-- center vertical
			y = parentSize.height * 0.5
		elseif 6 == layoutParameter.gravity then
			-- center horizontal
			x = parentSize.width * 0.5
		else
			-- use origin pos
			x = options.x
			y = options.y
			bUseOrigin = true
			print("CCSUILoader - modifyLayoutChildPos_ not support gravity:" .. layoutParameter.type)
		end

		if 1 == layoutParameter.gravity
			or 3 == layoutParameter.gravity
			or 6 == layoutParameter.gravity then
			x = ((options.anchorPointX or 0.5) - 0.5)*options.width + x
			y = options.y
		else
			x = options.x
			y = ((options.anchorPointY or 0.5) - 0.5)*options.height + y
		end
	elseif 2 == layoutParameter.type then
		local relativeChild = self:getPanelChild_(children, layoutParameter.relativeToName)
		local relativeRect
		if relativeChild then
			self:calcChildPosByName_(children, layoutParameter.relativeToName, parentSize)
			relativeRect = cc.rect(
				(relativeChild.options.x - (relativeChild.options.anchorPointX or 0.5) * relativeChild.options.width) or 0,
				(relativeChild.options.y - (relativeChild.options.anchorPointY or 0.5) * relativeChild.options.height) or 0,
				relativeChild.options.width or 0,
				relativeChild.options.height or 0)
		end

		-- calc pos on center anchor point (0.5, 0.5)
		if 1 == layoutParameter.align then
			-- top left
			x = options.width * 0.5
			y = parentSize.height - options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif 2 == layoutParameter.align then
			-- top center
			x = parentSize.width * 0.5
			y = parentSize.height - options.height * 0.5

			y = y - (layoutParameter.marginTop or 0)
		elseif 3 == layoutParameter.align then
			-- top right
			x = parentSize.width - options.width * 0.5
			y = parentSize.height - options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif 4 == layoutParameter.align then
			-- left center
			x = options.width * 0.5
			y = parentSize.height*0.5

			x = x + (layoutParameter.marginLeft or 0)
		elseif 5 == layoutParameter.align then
			-- center
			x = parentSize.width * 0.5
			y = parentSize.height*0.5
		elseif 6 == layoutParameter.align then
			-- right center
			x = parentSize.width - options.width * 0.5
			y = parentSize.height*0.5

			x = x - (layoutParameter.marginRight or 0)
		elseif 7 == layoutParameter.align then
			-- left bottom
			x = options.width * 0.5
			y = options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 8 == layoutParameter.align then
			-- bottom center
			x = parentSize.width * 0.5
			y = options.height * 0.5

			y = y + (layoutParameter.marginDown or 0)
		elseif 9 == layoutParameter.align then
			-- right bottom
			x = parentSize.width - options.width * 0.5
			y = options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 10 == layoutParameter.align then
			-- location above left
			x = relativeRect.x + options.width * 0.5
			y = relativeRect.y + relativeRect.height + options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 11 == layoutParameter.align then
			-- location above center
			x = relativeRect.x + relativeRect.width * 0.5
			y = relativeRect.y + relativeRect.height + options.height * 0.5

			y = y + (layoutParameter.marginDown or 0)
		elseif 12 == layoutParameter.align then
			-- location above right
			x = relativeRect.x + relativeRect.width - options.width * 0.5
			y = relativeRect.y + relativeRect.height + options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 13 == layoutParameter.align then
			-- location left top
			x = relativeRect.x - options.width * 0.5
			y = relativeRect.y + relativeRect.height - options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif 14 == layoutParameter.align then
			-- location left center
			x = relativeRect.x - options.width * 0.5
			y = relativeRect.y + relativeRect.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
		elseif 15 == layoutParameter.align then
			-- location left bottom
			x = relativeRect.x - options.width * 0.5
			y = relativeRect.y + options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 16 == layoutParameter.align then
			-- location right top
			x = relativeRect.x + relativeRect.width + options.width * 0.5
			y = relativeRect.y + relativeRect.height - options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginTop or 0)
		elseif 17 == layoutParameter.align then
			-- location right center
			x = relativeRect.x + relativeRect.width + options.width * 0.5
			y = relativeRect.y + relativeRect.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
		elseif 18 == layoutParameter.align then
			-- location right bottom
			x = relativeRect.x + relativeRect.width + options.width * 0.5
			y = relativeRect.y + options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif 19 == layoutParameter.align then
			-- location below left
			x = relativeRect.x + options.width * 0.5
			y = relativeRect.y - options.height * 0.5

			x = x + (layoutParameter.marginLeft or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif 20 == layoutParameter.align then
			-- location below center
			x = relativeRect.x + relativeRect.width * 0.5
			y = relativeRect.y - options.height * 0.5

			y = y - (layoutParameter.marginTop or 0)
		elseif 21 == layoutParameter.align then
			-- location below right
			x = relativeRect.x + relativeRect.width - options.width * 0.5
			y = relativeRect.y - options.height * 0.5

			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		else
			-- use origin pos
			x = options.x
			y = options.y
			bUseOrigin = true
			print("CCSUILoader - modifyLayoutChildPos_ not support align:" .. layoutParameter.align)
		end

		-- change pos on real anchor point
		x = ((options.anchorPointX or 0.5) - 0.5)*options.width + x
		y = ((options.anchorPointY or 0.5) - 0.5)*options.height + y
	elseif 0 == layoutParameter.type then
		x = options.x
		y = options.y
	else
		print("CCSUILoader - modifyLayoutChildPos_ not support type:" .. layoutParameter.type)
	end
	options.x = x
	options.y = y
	child.posFixed_ = true

end

function UIPanel:getPanelChild_(children, name)
	for _, v in ipairs(children) do
		if v.options.name == name then
			return v
		end
	end

	return
end

local UIPageView = cc.ui.UIPageView

function UIPageView:setPageColAndRow( column, row )
	self.column_= column or 1
	self.row_= row or 1
end

function UIPageView:getAllItems()
	return self.items_
end

local uiloader = cc.uiloader

-- private
function uiloader:loadAndParseFile(jsonFile)
	local fileUtil = cc.FileUtils:getInstance()
	local fullPath = fileUtil:fullPathForFilename(jsonFile)
	local jsonStr = cc.HelperFunc:getFileData(fullPath)
	local jsonVal = json.decode(jsonStr)

	local root = jsonVal.nodeTree
	if not root then
		root = jsonVal.widgetTree
	end
	if not root then
		printInfo("CCSUILoader - parserJson havn't found root node")
		return
	end
	self:prettyJson(root)

	return root, jsonVal
end

function uiloader:loadEx(sFilePath)
	local jsonNode, jsonVal = cc.uiloader:loadAndParseFile( sFilePath )
	return cc.uiloader:loadFromJson( jsonVal )
end

function uiloader:loadFromJson(json)
	if not json then
		print("uiloader - load file fail:" .. json)
		return
	end

	local node
	local w
	local h
	
	if self:isScene_(json) then
		node, w, h = CCSSceneLoader:load(json)
	else
		node, w, h = CCSUILoader:load(json)
	end

	return node, w, h
end

function uiloader:prettyJson(json)
	local setZOrder
	setZOrder = function(node, isParentScale)
		if isParentScale then
        	node.options.ZOrder = node.options.ZOrder or 0 + 3
		end

		if not node.children then
			print("CCSUILoader children is nil")
			return
		end
		if 0 == #node.children then
			return
		end

        for i,v in ipairs(node.children) do
			setZOrder(v, node.options.scale9Enable)
        end
	end

	setZOrder(json)
end
---------------------------------------------------------------------------------------------
local UILabel = cc.ui.UILabel

function UILabel:setLabelGray( bIsGray )
	local options = self.options
	if options == nil then
		return
	end
	if bIsGray == true then
		self:setColor( cc.c3b(128, 128, 128 ) )
	else
		self:setColor( cc.c3b(options.colorR or 255, options.colorG or 255, options.colorB or 255 ) )
	end
end

local UIPushButton = cc.ui.UIPushButton

function UIPushButton:getButtonImage(state)
    return self.images_[state]
end

function UIPushButton:addButtonImageGray( state )
	local uiManager = _G.GAME_APP:GetUIManager()
	local filename = self:getButtonImage( state )
	if filename ~= nil and uiManager ~= nil then
		uiManager:createGraySpriteFrame( string.sub( filename, 2 ) )
	end
end

function UIPushButton:setButtonImage(state, image, ignoreEmpty)
    assert(state == UIPushButton.NORMAL
        or state == UIPushButton.PRESSED
        or state == UIPushButton.DISABLED,
        string.format("UIPushButton:setButtonImage() - invalid state %s", tostring(state)))
    UIPushButton.super.setButtonImage(self, state, image, ignoreEmpty)

    if state == UIPushButton.NORMAL then
        if not self.images_[UIPushButton.PRESSED] then
            self.images_[UIPushButton.PRESSED] = image
        end
    end

    return self
end

function UIPushButton:setButtonEnabled(enabled,autoGray)
	if autoGray == nil then
		autoGray = false
	end
	if enabled == false and autoGray == true then
		self:setGrayStateUseNormalSprite( UIPushButton.DISABLED )
	end
    self:setTouchEnabled(enabled)
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = UIPushButton.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = UIPushButton.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    local jsonNode = self.jsonNode
    if jsonNode ~= nil then
    	for i, v in ipairs( jsonNode.children ) do
    		local options = v.options
    		if options ~= nil and v.classname == "Label" then
				local childNode = ccuiloader_seekNodeEx( self, options.name )
				if childNode ~= nil then
					if enabled == true then
						childNode:setColor( cc.c3b(options.colorR or 255, options.colorG or 255, options.colorB or 255 ) )
					else
						childNode:setColor( cc.c3b(128, 128, 128 ) )
					end
				end
			end
		end
    end
    return self
end

function UIPushButton:setGrayStateUseNormalSprite( state )
    assert(state == UIPushButton.NORMAL
    or state == UIPushButton.PRESSED
    or state == UIPushButton.DISABLED,
    string.format("UIPushButton:setGrayStateUseNormalSprite() - invalid state %s", tostring(state)))
	self:addButtonImageGray( cc.ui.UIPushButton.NORMAL )
    local sImgName = self:getButtonImage( cc.ui.UIPushButton.NORMAL )
    if sImgName ~= nil then    	
    	local sGrayImgName = string.gsub( sImgName, ".png", "___gray.png" )
    	self:setButtonImage( state, sGrayImgName )
    end
end

function UIPushButton:getButtonSize()
	if self.sprite_[1] == nil then
		return
	end
	return self.sprite_[1]:getContentSize()
end

function UIPushButton:showButtonGlowEffect( bShow )
	local uiManager = _G.GAME_APP:GetUIManager()
	if uiManager == nil then
		return
	end
	if bShow == true then
		uiManager:addButtonGlowEffect( self, self:getButtonSize() )	
	else
		local nTag = 808080808
		local childNode = self:getChildByTag(nTag)
		if childNode == nil then
			return
		end
		childNode:stopAllActions()
		childNode:removeFromParentAndCleanup(true)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------
function uiloader:createOneFromJson(json,transX,transY,parent)
	return CCSUILoader:generateOneUINode(json,transX,transY,parent)
end

-- generate a ui node and invoke self to generate child ui node
function CCSUILoader:generateOneUINode(jsonNode,transX,transY,parent)
	transX = transX or 0
	transY = transY or 0
	local clsName = jsonNode.classname
	local options = jsonNode.options
	options.x = options.x or 0
	options.y = options.y or 0
	options.x = options.x + transX
	options.y = options.y + transY
	local uiNode = self:createUINode(clsName, options, parent )
	if not uiNode then
		return
	end
	if clsName == "Label" then
		uiNode:setSystemFontName( CONFIG_DEFAULT_TTF or "" )
	end
	uiNode.classname = clsName
	self:modifyPanelChildPos_(clsName, options.adaptScreen, uiNode:getContentSize(), jsonNode.children)
	
	-- ccs中父节点的原点在父节点的锚点位置，这里用posTrans作转换
	local posTrans = uiNode:getAnchorPoint()
	local parentSize = uiNode:getContentSize()
	posTrans.x = posTrans.x * parentSize.width
	posTrans.y = posTrans.y * parentSize.height
	uiNode.PosTrans = posTrans
	uiNode.name = options.name or "unknow node"

	if options.fileName then
		uiNode:setSpriteFrame(options.fileName)
	end

	if options.flipX then
		if uiNode.setFlipX then
			uiNode:setFlipX(options.flipX)
		end
	end
	if options.flipY then
		if uiNode.setFlipY then
			uiNode:setFlipY(options.flipY)
		end
	end
	uiNode:setRotation(options.rotation or 0)

	uiNode:setScaleX((options.scaleX or 1) * uiNode:getScaleX())
	uiNode:setScaleY((options.scaleY or 1) * uiNode:getScaleY())
	uiNode:setVisible(options.visible)
	uiNode:setLocalZOrder(options.ZOrder or 0)
	uiNode.ZOrder = options.ZOrder or 0
	-- uiNode:setGlobalZOrder(options.ZOrder or 0)
	uiNode:setTag(options.tag or 0)

	local emptyNode
	if "ScrollView" == clsName then
		emptyNode = cc.Node:create()
		emptyNode:setPosition(options.x, options.y)
		uiNode:addScrollNode(emptyNode)
		uiNode.emptyNode = emptyNode
	end

	return uiNode
end