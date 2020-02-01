using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CellController : MonoBehaviour
{
    public enum CellState
    {
        Healty,
        Infected,
    }

    public UnityJellySprite jellySprite;
    public float forceAngleSpeed = 30f;
    public float forceIntensity = 5f;
    public float forceOffset = 50f;
    public float perlinScale = 1f;
    public Vector3[] referencePointsPos;

    public void InitPos()
    {
        referencePointsPos = new Vector3[jellySprite.ReferencePoints.Count];

        Debug.Log("Init Pos");
        for (int i = 0; i < referencePointsPos.Length; ++i)
        {
            referencePointsPos[i] = jellySprite.ReferencePoints[i].transform.position;
            jellySprite.ReferencePoints[i].Body2D.simulated = false;

        }
    }

    public void Update()
    {
        if (jellySprite.ReferencePoints != null)
        {
            if (referencePointsPos == null || referencePointsPos.Length < 1)
            {
                InitPos();
            }

            for (int i = 0; i < jellySprite.ReferencePoints.Count; i += 2)
            {
                var pos = jellySprite.ReferencePoints[i].transform.position;
                float angle = (Mathf.PerlinNoise(pos.x * perlinScale + Time.time * forceOffset, pos.y * perlinScale + Time.time * forceOffset) * forceAngleSpeed) * Mathf.Deg2Rad;
                //jellySprite.ReferencePoints[i].Body2D.AddForce(new Vector2(Mathf.Sin(angle), Mathf.Cos(angle)) * forceIntensity );

                jellySprite.ReferencePoints[i].transform.position = new Vector3(Mathf.Sin(angle), Mathf.Cos(angle), 0) * forceIntensity
                    + referencePointsPos[i];

            }
        }
    }
}
