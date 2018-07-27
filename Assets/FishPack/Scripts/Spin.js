var rotateXspeed:float=0;
var rotateYspeed:float=90;
var rotateZspeed:float=0;

var local:boolean=false;

function Update () {

if (local==false)
{
transform.Rotate(rotateXspeed*Time.deltaTime, rotateYspeed*Time.deltaTime, rotateZspeed*Time.deltaTime, Space.World);
}


if (local==true)
{
transform.Rotate(rotateXspeed*Time.deltaTime, rotateYspeed*Time.deltaTime, rotateZspeed*Time.deltaTime);
}

}