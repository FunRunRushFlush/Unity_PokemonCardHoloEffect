using UnityEngine;

[System.Serializable]
public class SpringFloat
{
    public float current;
    public float target;
    public float velocity;

    [Range(0.01f, 1f)] public float stiffness;
    [Range(0.01f, 1f)] public float damping;

    public SpringFloat(float stiffness, float damping, float initial = 0f)
    {
        this.stiffness = stiffness;
        this.damping = damping;
        current = initial;
        target = initial;
        velocity = 0f;
    }

    public void Update()
    {
        velocity += (target - current) * stiffness;
        velocity *= (1f - damping);
        current += velocity;
    }


}


[System.Serializable]
public class SpringVector2
{
    public SpringFloat x;
    public SpringFloat y;

    public SpringVector2(float stiffness, float damping, float ix = 0f, float iy = 0f)
    {
        x = new SpringFloat(stiffness, damping, ix);
        y = new SpringFloat(stiffness, damping, iy);
    }

    public Vector2 Current => new Vector2(x.current, y.current);

    public void SetTarget(float tx, float ty)
    {
        x.target = tx;
        y.target = ty;
    }

    void Update()
    {
        x.Update();
        y.Update();
    }
}


[System.Serializable]
public class SpringVector3
{
    public SpringFloat x;
    public SpringFloat y;
    public SpringFloat z;

    public SpringVector3(float stiffness, float damping, float ix = 0f, float iy = 0f, float iz = 0f)
    {
        x = new SpringFloat(stiffness, damping, ix);
        y = new SpringFloat(stiffness, damping, iy);
        z = new SpringFloat(stiffness, damping, iz);
    }

    public void SetTarget(float tx, float ty, float tz)
    {
        x.target = tx;
        y.target = ty;
        z.target = tz;

    }

    // Update is called once per frame
    void Update()
    {
        x.Update();
        y.Update();
        z.Update();
    }

}
