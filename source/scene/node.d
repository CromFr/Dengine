module scene.node;

import std.stdio;
import derelict.opengl3.gl3;

public import base.vect3d;
public import base.callback;
public import gl3n.linalg;

abstract class Node {
	final this(ref Node parent, in Vect3Df pos, in Vect3Df rot) {
		m_parent = parent;
		if(m_parent !is null)
			m_parent.AddChild(this);
		m_pos = pos;
		m_matpos = mat4.translation(pos.x, pos.y, pos.z);
		m_rot = rot;
		m_matrot = mat4.identity;
		UpdateMatrix();
	}
	final ~this(){
		foreach(ref child ; m_children)
			child.destroy();
	}

	void AddChild(ref Node child){
		m_children~=child;
	}

	//Override-able functions
	void Render(ref mat4 proj, ref mat4 mdlview){}
	

	@property final {
		bool visible()const{return m_visible;}
		void visible(bool visible){m_visible = visible;}

		ref Node parent(){return m_parent;}
		void parent(ref Node parent){m_parent = parent;}

		//Callbacks
		ref Callback onRendered(){return m_onrendered;}
		ref Callback onUpdated(){return m_onupdated;}
	}

	/**
		Positions
	*/
	@property final {
		Vect3Df position()const{return m_pos;}
		void position(const ref Vect3Df pos){
			m_pos = pos;
			m_matpos = m_matpos.translation(pos.x, pos.y, pos.z);
		}

		//Vect3Df positionAbsolute(){
		//	//TODO Make function const
		//	Vect3Df ret;
		//	//ret+=this.m_pos;
		//	//const(Node)* p = &m_parent;
		//	//while(*p !is null){
		//	//	p = &p.m_parent;
		//	//	ret+=p.m_pos;
		//	//}
		//	Node p = this;
		//	do{
		//		ret+=p.m_pos;
		//	}while((p=p.parent) !is null);

		//	return ret;
		//}
		//void positionAbsolute(const ref Vect3Df pos){
		//	m_pos += pos-positionAbsolute;
		//}


		//Vect3Df positionToNode(ref Node node){
		//	return node.positionAbsolute - positionAbsolute;
		//}
		//void positionToNode(ref Node node, ref Vect3Df pos){
		//	m_pos += pos-positionToNode(node);
		//}
	}

	/**
		Rotations
	*/
	@property{
		//Vect3Df rotation()const{return m_rot;}
		//void rotation(const ref Vect3Df rot){
		//	m_rot = rot;
		//	m_matpos = translation(pos);
		//}

		//Vect3Df rotationAbsolute(){
		//	//TODO Make function const
		//	Vect3Df ret;
		//	//ret+=this.m_rot;
		//	//const(Node)* p = &m_parent;
		//	//while(*p !is null){
		//	//	p = &p.m_parent;
		//	//	ret+=p.m_rot;
		//	//}
		//	Node p = this;
		//	do{
		//		ret+=p.m_rot;
		//	}while((p=p.parent) !is null);

		//	return ret;
		//}
		//void rotationAbsolute(const ref Vect3Df rot){
		//	m_rot += rot-rotationAbsolute;
		//}


		//Vect3Df rotationToNode(ref Node node){
		//	return node.rotationAbsolute - rotationAbsolute;
		//}
		//void rotationToNode(ref Node node, ref Vect3Df rot){
		//	m_rot += rot-rotationToNode(node);
		//}
	}

	final{
		void Move(in Vect3Df mov){
			m_matpos = m_matpos.translate(mov.x, mov.y, mov.z);
			UpdateMatrix();
		}

		void RotateX(float degrees){
			m_matrot = m_matrot.rotatex(degrees*(PI/180.0));
			UpdateMatrix();
		}
		void RotateY(float degrees){
			m_matrot = m_matrot.rotatey(degrees*(PI/180.0));
			UpdateMatrix();
		}
		void RotateZ(float degrees){
			m_matrot = m_matrot.rotatez(degrees*(PI/180.0));
			UpdateMatrix();
		}

		void EngineRender(ref mat4 proj, mat4 mdlview){
			if(m_visible){
				mdlview = mdlview*m_matmodel;

				Render(proj, mdlview);
				m_onrendered.Execute();
				foreach(ref child ; m_children)child.EngineRender(proj, mdlview);
			}
		}

		void Update(bool updateChildren=true){
			m_onupdated.Execute();
			if(updateChildren)
				foreach(ref child ; m_children)child.Update();
		}

	}



	mixin template NodeCtor()
	{
		this(ref Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0)){
			super(parent, pos, rot);
		}
	}

protected:
	auto m_onrendered = new Callback;
	auto m_onupdated = new Callback;
	mat4 m_matmodel;

private:
	Vect3Df m_pos, m_rot, m_scale;
	mat4 m_matpos, m_matrot, m_matscale;
	void UpdateMatrix(){m_matmodel = m_matpos*m_matrot;}
	

	bool m_visible = true;

	Node m_parent;
	Node m_children[];

}








//unittest {
//	import unit;
//	import scene.nodecontainer;

//	PrintStart();

//	Node nullnode = null;
//	Node A = new NodeContainer(nullnode, Vect3Df(2,2,2), Vect3Df(1,1,1));
//	Node B = new NodeContainer(A, Vect3Df(5,5,5), Vect3Df(33,33,33));
//	Node C = new NodeContainer(A, Vect3Df(8,8,8), Vect3Df(11,11,11));

//	assert(A.position == Vect3Df(2,2,2));
//	assert(A.positionAbsolute == Vect3Df(2,2,2));

//	assert(B.position == Vect3Df(5,5,5));
//	assert(B.positionAbsolute == Vect3Df(7,7,7));

//	assert(C.position == Vect3Df(8,8,8));
//	assert(C.positionAbsolute == Vect3Df(10,10,10));

//	assert(C.positionToNode(A) == Vect3Df(-8,-8,-8));
//	assert(C.positionToNode(B) == Vect3Df(-3,-3,-3));


//	assert(A.rotation == Vect3Df(1,1,1));
//	assert(A.rotationAbsolute == Vect3Df(1,1,1));

//	assert(B.rotation == Vect3Df(33,33,33));
//	assert(B.rotationAbsolute == Vect3Df(34,34,34));

//	assert(C.rotation == Vect3Df(11,11,11));
//	assert(C.rotationAbsolute == Vect3Df(12,12,12));

//	assert(C.rotationToNode(A) == Vect3Df(-11,-11,-11));
//	assert(C.rotationToNode(B) == Vect3Df(22,22,22));

//	PrintEnd();
//}