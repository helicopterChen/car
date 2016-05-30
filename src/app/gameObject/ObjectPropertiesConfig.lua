local ObjectPropertiesConfig = {};

--赛车对象
ObjectPropertiesConfig["CGameCar"] = 
{
	--这里的属性排列顺序，和服务器发送来的字节顺序相关,以后如果服务器进行调整，客户端直接调整这里的顺序就行
	{ AttriName = "X",   		Type = "int16",  SYN = true,  DefaultVal = "0"  },	--x位移
	{ AttriName = "Y",   		Type = "int16",  SYN = true,  DefaultVal = "0"  },	--y位置	
	{ AttriName = "View",   	Type = "String", SYN = true,  DefaultVal = ""  },	--外观
	{ AttriName = "Type", 	 	Type = "uint32", SYN = true,  DefaultVal = "0", },	--类型
}

--固定塔
ObjectPropertiesConfig["CAnchorTower"] = 
{
	{ AttriName = "X",   		Type = "int16",   SYN = true,  DefaultVal = "0"  },	--x位移
	{ AttriName = "Y",   		Type = "int16",   SYN = true,  DefaultVal = "0"  },	--y位置
	{ AttriName = "View",   	Type = "String",  SYN = true,  DefaultVal = ""  },	--外观
	{ AttriName = "Rotation", 	Type = "float",   SYN = true,  DefaultVal = "0"  },	--旋转角度
	{ AttriName = "RadiusMin",  Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--最小影响半径
	{ AttriName = "RadiusMax",  Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--最大影响半径
	{ AttriName = "IsReverse",  Type = "uint8",   SYN = true,  DefaultVal = "0"  },	--是否反向塔
	{ AttriName = "ArrowAngle", Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--指向角度
	{ AttriName = "AngleSector",Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--扇区大小
}

--磁力塔
ObjectPropertiesConfig["CMagneticTower"] = 
{
	{ AttriName = "X",   		Type = "int16",   SYN = true,  DefaultVal = "0"  },	--x位移
	{ AttriName = "Y",   		Type = "int16",   SYN = true,  DefaultVal = "0"  },	--y位置
	{ AttriName = "View",   	Type = "String",  SYN = true,  DefaultVal = ""  },	--外观
	{ AttriName = "RadiusMin",  Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--最小影响半径
	{ AttriName = "RadiusMax",  Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--最大影响半径
	{ AttriName = "IsReverse",  Type = "uint8",   SYN = true,  DefaultVal = "0"  },	--是否反向塔
	{ AttriName = "ArrowAngle", Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--指向角度
	{ AttriName = "RectWidth",	Type = "uint32",  SYN = true,  DefaultVal = "0"  },	--扇区大小

}

return ObjectPropertiesConfig