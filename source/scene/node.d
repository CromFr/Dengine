module scene.node;

import std.stdio;
import derelict.opengl3.gl3;
import math.utils;

public import base.vect3d;
public import base.callback;
public import gl3n.linalg;

/**
	Node in the 3d scene
*/
abstract class Node {
	/**
		Constructs the node on a parent node
		Notes: The first parent is created by the engine, and is retrieved with engine.rootNode. If parent is null, the node will not be updated nor rendered
	*/
	final this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)) {
		m_parent = parent;
		if(m_parent !is null)
			m_parent.AddChild(this);

		position = pos;
		rotation = rot;
		scale = sca;
	}
	final ~this(){
		foreach(ref child ; m_children)
			child.destroy();
	}

	/**
		Registers a node as the child of this node
	*/
	void AddChild(ref Node child){
		m_children~=child;
	}

	/**
		Override it if the node must be rendered
		Warning: Should not be called manually
	*/
	void Render(ref mat4 proj, ref mat4 mdlview){}
	

	@property final {
		/**
			Is node rendered
		*/
		bool visible()const{return m_visible;}

		/**
			ditto
		*/
		void visible(bool visible){m_visible = visible;}

		/**
			Parent node
		*/
		ref Node parent(){return m_parent;}

		/**
			ditto
		*/
		void parent(ref Node parent){m_parent = parent;}

		/**
			Callback to execute when the node is rendered
		*/
		ref Callback onRendered(){return m_onrendered;}

		/**
			Callback to execute when the node is updated
		*/
		ref Callback onUpdated(){return m_onupdated;}
	}

	/**
		Positions
	*/
	@property final {
		Vect3Df position()const{return m_pos;}
		void position(in Vect3Df pos){
			m_pos = pos;
			m_matpos = mat4.translation(m_pos.x, m_pos.y, m_pos.z);
			m_matChange = true;
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
	@property final {
		Vect3Df rotation()const{return m_rot*(180.0/PI);}
		void rotation(in Vect3Df rot){
			//m_rot = rot*(PI/180.0);
			//m_matrot = RotationMatrix(m_rot);
			//m_matChange = true;
			m_rot = Vect3Df(0,0,0);
			m_matrot = mat4.identity;
			RotateX(rot.x);
			RotateY(rot.y);
			RotateZ(rot.z);
		}
	}

	@property final {
		Vect3Df scale()const{return m_scale;}
		void scale(in Vect3Df scale){
			m_scale = scale;
			m_matscale = mat4.scaling(scale.x, scale.y, scale.z);
			m_matChange = true;
		}
	}

	final{
		void Move(in Vect3Df mov){
			m_matpos = m_matpos.translate(mov.x, mov.y, mov.z);
			m_matChange = true;
		}

		void RotateX(float degrees){
			float fRad = degrees*(PI/180.0);
			m_rot.x = m_rot.x+fRad;
			m_matrot = m_matrot.rotatex(-fRad);
			m_matChange = true;
		}
		void RotateY(float degrees){
			float fRad = degrees*(PI/180.0);
			m_rot.y = m_rot.y+fRad;
			m_matrot = m_matrot.rotatey(-fRad);
			m_matChange = true;
		}
		void RotateZ(float degrees){
			float fRad = degrees*(PI/180.0);
			m_rot.z = m_rot.z+fRad;
			m_matrot = m_matrot.rotatez(-fRad);
			m_matChange = true;
		}

		void Resize(in Vect3Df ratio){
			m_scale *= ratio;
			m_matscale = m_matscale * mat4.scaling(scale.x, scale.y, scale.z);
			m_matChange = true;
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

			if(m_matChange)
				UpdateMatrix();

			if(updateChildren)
				foreach(ref child ; m_children)child.Update();
		}

	}



	mixin template NodeCtor()
	{
		this(Node parent, in Vect3Df pos=Vect3Df(0,0,0), in Vect3Df rot=Vect3Df(0,0,0), in Vect3Df sca=Vect3Df(1,1,1)){
			super(parent, pos, rot, sca);
		}
	}

protected:
	auto m_onrendered = new Callback;
	auto m_onupdated = new Callback;
	mat4 m_matmodel;

private:
	bool m_matChange = true;
	Vect3Df m_pos, m_rot, m_scale;
	mat4 m_matpos, m_matrot, m_matscale;
	void UpdateMatrix(){
		m_matmodel = m_matpos*m_matrot*m_matscale;
		m_matChange = false;
	}
	

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