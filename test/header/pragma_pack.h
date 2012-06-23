#pragma once

//[],false
struct StructDefaultA
{
	char a;
	int b;
};

#pragma pack(2)
//[],2
struct Struct2A
{
	char a;
	int b;
};
#pragma pack(push,4)
#pragma pack(push)
//[2,4],4
struct Struct4A
{
	char a;
	int b;
};
#pragma pack(pop)
//[2],4
struct Struct4B
{
	char a;
	int b;
};
#pragma pack(pop)
//[],2
struct Struct2B
{
	char a;
	int b;
};
#pragma pack(pop)
//[],2
struct Struct2C
{
	char a;
	int b;
};
#pragma pack(push,16)
#pragma pack(push,id_a,1)
#pragma pack(push,8)
//[2,16,1],8
struct Struct8A
{
	char a;
	int b;
};
#pragma pack(pop,id_a)
//[2],16
struct Struct16A
{
	char a;
	int b;
};
#pragma pack(pop,4)
//[],4
struct Struct4C
{
	char a;
	int b;
};

