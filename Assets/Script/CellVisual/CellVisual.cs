using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CellVisual : MonoBehaviour
{
    public enum CellState
    {
        Healthy,
        Infected,
    }

    [System.Serializable]
    public struct ColorData
    {
        public CellState state;
        public Color CellColor;
        public Color CoreColor;
    }

    [Header("====== State ======")]
    public CellState m_state;

    [Header("==== Reference =====")]
    public UnityJellySprite jellySprite;
    public SpriteRenderer core;

    [Header("====== Data ======")]
    public float forceAngleSpeed = 600f;
    public float forceIntensity = 0.5f;
    public float forceOffset = 0.5f;
    public float perlinScale = 0.05f;
    public Vector3[] referencePointsPos;

    [Header("====== Color ======")]
    public List<ColorData> colorDataList;
    public float fadeDuration = 0.5f;


    public void InitPos()
    {
        referencePointsPos = new Vector3[jellySprite.ReferencePoints.Count];

        Debug.Log("Init Pos");
		for (int i = 0; i < referencePointsPos.Length; ++i)
		{
			referencePointsPos[i] = jellySprite.ReferencePoints[i].transform.position;

            float offsetAngle = Mathf.PerlinNoise(referencePointsPos[i].x , referencePointsPos[i].y ) * Mathf.PI * 2f  ;

            Debug.Log("Offser Angle " + offsetAngle + " pos " + referencePointsPos[i]);

            referencePointsPos[i] += new Vector3( Mathf.Sin(offsetAngle) , Mathf.Cos(offsetAngle) , 0) * forceIntensity * 0.33f;

            jellySprite.ReferencePoints[i].transform.position = referencePointsPos[i];

			jellySprite.ReferencePoints[i].Body2D.simulated = false;

		}
    }

    public void UpdateFloating()
    {
        if (jellySprite.ReferencePoints != null)
        {
            if (referencePointsPos == null || referencePointsPos.Length < 1)
            {
                InitPos();
            }

            for (int i = 0; i < jellySprite.ReferencePoints.Count; i++)
            {
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

    public void Update()
    {
        UpdateFloating();
    }

    public void SetStateTo( CellState state )
    {
        if ( m_state != state )
        {
            var colorData = colorDataList.Find((x) => x.state == state);

            var cellMat = jellySprite.GetComponent<Renderer>().sharedMaterial;

            DOTween.To(() => cellMat.color, (x) => cellMat.color = x, colorData.CellColor, fadeDuration);

            DOTween.To(() => cellMat.GetFloat("_InfectRate"), (x) => cellMat.SetFloat("_InfectRate",x), state == CellState.Infected? 1f : 0, fadeDuration); ;

            var coreMat = core.GetComponent<Renderer>().sharedMaterial;
            DOTween.To(() => coreMat.color, (x) => coreMat.color = x, colorData.CoreColor, fadeDuration);

            DOTween.To(() => coreMat.GetFloat("_InfectRate"), (x) => coreMat.SetFloat("_InfectRate", x), state == CellState.Infected? 1f : 0 , fadeDuration); ;

        }

        m_state = state;
    }
}
