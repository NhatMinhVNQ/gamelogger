--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_95CAC = 0;
			while true do
				if (FlatIdent_95CAC == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_76979 = 0;
			local Res;
			while true do
				if (FlatIdent_76979 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_69270 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_69270 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_69270 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_69270 = 1;
			end
		end
	end
	local function gFloat()
		local FlatIdent_7126A = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_7126A == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_7126A = 2;
			end
			if (FlatIdent_7126A == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_44839 = 0;
						while true do
							if (FlatIdent_44839 == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_7126A == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_7126A = 1;
			end
			if (FlatIdent_7126A == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_7126A = 3;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_25011 = 0;
			while true do
				if (FlatIdent_25011 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_7DD24 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (2 == FlatIdent_7DD24) then
				for Idx = 1, gBits32() do
					local Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_104D4 = 0;
							while true do
								if (FlatIdent_104D4 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_940A0 = 0;
							while true do
								if (FlatIdent_940A0 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_7DD24 == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local Type = gBits8();
					local Cons;
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
				end
				Chunk[3] = gBits8();
				FlatIdent_7DD24 = 2;
			end
			if (FlatIdent_7DD24 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_7DD24 = 1;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_6053C = 0;
				while true do
					if (FlatIdent_6053C == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_6053C = 1;
					end
					if (FlatIdent_6053C == 1) then
						if (Enum <= 11) then
							if (Enum <= 5) then
								if (Enum <= 2) then
									if (Enum <= 0) then
										local B;
										local T;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									elseif (Enum > 1) then
										local A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
									else
										local A = Inst[2];
										Stk[A](Stk[A + 1]);
									end
								elseif (Enum <= 3) then
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								elseif (Enum == 4) then
									if (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 8) then
								if (Enum <= 6) then
									local A = Inst[2];
									local T = Stk[A];
									local B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								elseif (Enum == 7) then
									do
										return;
									end
								else
									local FlatIdent_99389 = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_99389 == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
										if (FlatIdent_99389 == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_99389 = 1;
										end
									end
								end
							elseif (Enum <= 9) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							elseif (Enum > 10) then
								local FlatIdent_7A75F = 0;
								local A;
								while true do
									if (FlatIdent_7A75F == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_7A75F = 6;
									end
									if (FlatIdent_7A75F == 0) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_7A75F = 1;
									end
									if (FlatIdent_7A75F == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_7A75F = 3;
									end
									if (FlatIdent_7A75F == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_7A75F = 4;
									end
									if (FlatIdent_7A75F == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_7A75F == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_7A75F = 5;
									end
									if (FlatIdent_7A75F == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_7A75F = 2;
									end
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A]();
							end
						elseif (Enum <= 17) then
							if (Enum <= 14) then
								if (Enum <= 12) then
									Stk[Inst[2]] = {};
								elseif (Enum > 13) then
									local FlatIdent_817B0 = 0;
									local B;
									while true do
										if (FlatIdent_817B0 == 0) then
											B = Stk[Inst[4]];
											if not B then
												VIP = VIP + 1;
											else
												local FlatIdent_52551 = 0;
												while true do
													if (FlatIdent_52551 == 0) then
														Stk[Inst[2]] = B;
														VIP = Inst[3];
														break;
													end
												end
											end
											break;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 15) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							elseif (Enum > 16) then
								Stk[Inst[2]] = Inst[3];
							else
								local FlatIdent_287B5 = 0;
								local B;
								local K;
								while true do
									if (FlatIdent_287B5 == 0) then
										B = Inst[3];
										K = Stk[B];
										FlatIdent_287B5 = 1;
									end
									if (FlatIdent_287B5 == 1) then
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										break;
									end
								end
							end
						elseif (Enum <= 20) then
							if (Enum <= 18) then
								VIP = Inst[3];
							elseif (Enum > 19) then
								local B;
								local A;
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 22) then
							if (Enum == 21) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local FlatIdent_D79D = 0;
								local K;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_D79D) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_D79D = 3;
									end
									if (FlatIdent_D79D == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (4 == FlatIdent_D79D) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										FlatIdent_D79D = 5;
									end
									if (FlatIdent_D79D == 0) then
										K = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = {};
										FlatIdent_D79D = 1;
									end
									if (FlatIdent_D79D == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_D79D = 2;
									end
									if (3 == FlatIdent_D79D) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_D79D = 4;
									end
									if (FlatIdent_D79D == 7) then
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_D79D = 8;
									end
									if (FlatIdent_D79D == 6) then
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										FlatIdent_D79D = 7;
									end
									if (5 == FlatIdent_D79D) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_D79D = 6;
									end
								end
							end
						elseif (Enum > 23) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Inst[3] do
								Insert(T, Stk[Idx]);
							end
						else
							Stk[Inst[2]] = Stk[Inst[3]];
						end
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!273O00028O0003793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F3132352O302O323736393530313031323035392F55614C38333675677071653877525665612D4D634F6953705838334D7054344A34615A3538326B7836554B51526F486E6F6734466C48772O626C6E53442D5A775F56334D030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E026O00F03F03063O00656D6265647303053O007469746C6503483O00203C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E03283O00E289AB205B205374617475732047616D65205D20E289AA3O600A2O204578656375746F72203A2003103O006964656E746966796578656375746F7203183O003O60203O60436F6D696E6720532O6F6E3O2E3O6003053O00636F6C6F7203083O00746F6E756D626572023O0080769A5C4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D653A2003053O0076616C756503043O0067616D65030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403043O004E616D6503063O00696E6C696E652O01030B3O00482O747053657276696365030A3O004A534F4E456E636F6465027O0040030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E2O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273004C3O0012113O00014O0003000100053O0026043O0009000100010004123O00090001001211000100024O000C00063O00010030150006000300042O0017000200063O0012113O00053O0026043O0035000100050004123O003500012O000C00063O00012O0016000700016O00083O000400302O00080007000800122O0009000A3O00122O000A000B6O000A0001000200122O000B000C6O00090009000B00102O00080009000900122O0009000E3O001211000A000F4O001400090002000200102O0008000D00094O000900016O000A3O000300302O000A0011001200122O000B00143O00202O000B000B001500122O000D00166O000B000D000200202O000B000B0017001213000D00143O00202O000D000D00184O000B000D000200202O000B000B001900102O000A0013000B00302O000A001A001B4O0009000100010010050008001000092O00060007000100010010050006000600072O000D000300063O00122O000600143O00202O00060006001500122O0008001C6O00060008000200202O00060006001D4O000800036O0006000800024O000400063O00124O001E3O0026043O00020001001E0004123O000200010012130006001F3O00060E00050042000100060004123O00420001001213000600203O00060E00050042000100060004123O00420001001213000600213O00060E00050042000100060004123O00420001001213000600223O0020090005000600202O0017000600054O000B00073O000400102O00070023000100102O00070024000400302O00070025002600102O0007002700024O00060002000100044O004B00010004123O000200012O00073O00017O00", GetFEnv(), ...);
