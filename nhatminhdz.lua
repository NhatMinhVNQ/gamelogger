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
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
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
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_2BD95 = 0;
		local a;
		while true do
			if (FlatIdent_2BD95 == 1) then
				return a;
			end
			if (FlatIdent_2BD95 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_60EA1 = 0;
				while true do
					if (FlatIdent_60EA1 == 0) then
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
	local function gString(Len)
		local FlatIdent_31A5A = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_31A5A == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_31A5A = 3;
			end
			if (FlatIdent_31A5A == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_31A5A = 2;
			end
			if (FlatIdent_31A5A == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_31A5A == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_31A5A = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
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
		for Idx = 1, gBits32() do
			local FlatIdent_104D4 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_104D4 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_940A0 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (1 == FlatIdent_940A0) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
								end
								FlatIdent_940A0 = 2;
							end
							if (FlatIdent_940A0 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_940A0 = 3;
							end
							if (FlatIdent_940A0 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_940A0 = 1;
							end
							if (FlatIdent_940A0 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
						end
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
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
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 11) then
					if (Enum <= 5) then
						if (Enum <= 2) then
							if (Enum <= 0) then
								VIP = Inst[3];
							elseif (Enum == 1) then
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
							else
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 3) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Enum > 4) then
							local K;
							local B;
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							B = Inst[3];
							K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 8) then
						if (Enum <= 6) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						elseif (Enum == 7) then
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
						else
							local FlatIdent_9147D = 0;
							local B;
							while true do
								if (FlatIdent_9147D == 0) then
									B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										Stk[Inst[2]] = B;
										VIP = Inst[3];
									end
									break;
								end
							end
						end
					elseif (Enum <= 9) then
						local A = Inst[2];
						local T = Stk[A];
						local B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
						end
					elseif (Enum == 10) then
						do
							return;
						end
					else
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum <= 17) then
					if (Enum <= 14) then
						if (Enum <= 12) then
							local FlatIdent_6A83E = 0;
							local A;
							local T;
							while true do
								if (FlatIdent_6A83E == 1) then
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
									break;
								end
								if (FlatIdent_6A83E == 0) then
									A = Inst[2];
									T = Stk[A];
									FlatIdent_6A83E = 1;
								end
							end
						elseif (Enum == 13) then
							Stk[Inst[2]] = Inst[3];
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 15) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					elseif (Enum > 16) then
						local FlatIdent_12544 = 0;
						local B;
						local K;
						while true do
							if (FlatIdent_12544 == 0) then
								B = Inst[3];
								K = Stk[B];
								FlatIdent_12544 = 1;
							end
							if (FlatIdent_12544 == 1) then
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								break;
							end
						end
					else
						local A = Inst[2];
						Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 20) then
					if (Enum <= 18) then
						local B;
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
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
					elseif (Enum > 19) then
						local T;
						local B;
						local A;
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
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
					else
						Stk[Inst[2]] = Env[Inst[3]];
					end
				elseif (Enum <= 22) then
					if (Enum == 21) then
						Stk[Inst[2]] = Stk[Inst[3]];
					else
						local FlatIdent_74348 = 0;
						local A;
						while true do
							if (FlatIdent_74348 == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								break;
							end
						end
					end
				elseif (Enum > 23) then
					local A;
					Stk[Inst[2]] = {};
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A](Stk[A + 1]);
					VIP = VIP + 1;
					Inst = Instr[VIP];
					VIP = Inst[3];
				else
					local A = Inst[2];
					local B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!293O00028O00026O00F03F03793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F31323634383936352O303639383435323031392F757A6E523759545249563759765471676261534F646B522O637A766F706A367030582O5236754E305351306D353271703864764F4879526A7248785371384E6E33466873030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E027O004003063O00656D6265647303053O007469746C6503473O003C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E030B3O0020557365724E616D653A2003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203043O004E616D6503043O007479706503043O007269636803053O00636F6C6F7203083O00746F6E756D626572023O00E02OFF6F4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D65203A03053O0076616C7565030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403063O00696E6C696E652O01030B3O00482O747053657276696365030A3O004A534F4E456E636F6465030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E2O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273005E3O00120D3O00014O0007000100053O0026043O00110001000100044O0011000100120D000600013O002604000600090001000200044O0009000100120D3O00023O00044O00110001002604000600050001000100044O0005000100120D000100034O000B00073O000100302O0007000400054O000200073O00122O000600023O00044O000500010026043O00470001000200044O0047000100120D000600013O002604000600180001000200044O0018000100120D3O00063O00044O00470001002604000600140001000100044O001400012O000200073O00012O0005000800016O00093O000500302O00090008000900122O000A000B3O00122O000B000C3O00202O000B000B000D00202O000B000B000E00202O000B000B000F4O000A000A000B00102O0009000A000A00300E000900100011002O12000A00133O00122O000B00146O000A0002000200102O00090012000A4O000A00016O000B3O000300302O000B0016001700122O000C000C3O00202O000C000C001900122O000E001A4O000F000C000E0002002014000C000C001B00122O000E000C3O00202O000E000E001C4O000C000E000200202O000C000C000F00102O000B0018000C00302O000B001D001E4O000A0001000100100300090015000A2O00090008000100010010030007000700082O0001000300073O00122O0007000C3O00202O00070007001900122O0009001F6O00070009000200202O0007000700204O000900036O0007000900024O000400073O00122O000600023O00044O001400010026043O00020001000600044O00020001001213000600213O000608000500540001000600044O00540001001213000600223O000608000500540001000600044O00540001001213000600233O000608000500540001000600044O00540001001213000600243O0020060005000600222O0015000600054O001800073O000400102O00070025000100102O00070026000400302O00070027002800102O0007002900024O00060002000100044O005D000100044O000200012O000A3O00017O00", GetFEnv(), ...);